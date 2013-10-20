/**
 * Evaluator
 *
 * Evaluate variables, loops, conditions, etc.
 * Join nested selectors
 */
var TransformerAsync = require('tree-transformer-async');
var RooleError = require('roole-error');
var Node = require('roole-node');
var parser = require('roole-parser');
var Promise = require('promise-now');
var anyFirst = require('promise-any-first');
var Range = require('natural-range');
var path = require('path-br');
var loader = require('floader');
var builtin = require('roole-builtin');

var Scope = require('./Scope');
var Mixiner = require('./Mixiner');
var Normalizer = require('./Normalizer');
var SelectorJoiner = require('./SelectorJoiner');
var MediaQueryJoiner = require('./MediaQueryJoiner');

var protocolRe = /^(?:[\w-]+:)?\/\/|^data:/i;
var prefixedPathRe = /^\.\/|^\.$|^\.\.\/|^\.\.$/;
var isAbsolute = function (filename) { return filename.charAt(0) === '/'; };
var noop = function () {};

module.exports = Evaluator;
Evaluator.builtin = builtin;

function Evaluator(options) {
	if (!options) options = {};
	if (!options.imports) options.imports = {};
	if (!options.out) options.out = options.base;
	if (!options.global) options.global = {};

	this.options = options;
	this.imported = {};

	var global = {};
	Object.keys(builtin).forEach(function (name) {
		global[name] = Node.toNode(builtin[name]);
	});
	Object.keys(options.global).forEach(function (name) {
		var node = Node.toNode(options.global[name]);
		if (!node) throw new Error("cannot convert option global." + name + " to node");
		global[name] = node;
	});
	this.scope = new Scope(global);
}

Evaluator.prototype = new TransformerAsync();

Evaluator.prototype.evaluate = function (node) {
	return this.visit(node).then(function (node) {
		node = new Mixiner(this.options).mixin(node);
		return new Normalizer(this.options).normalize(node);
	});
};

Evaluator.prototype.visit_node = function (node) {
	if (!node.children) return;

	return this.visit(node.children).then(function () {
		return node;
	});
};

Evaluator.prototype.visit_ruleset = function (ruleset) {
	var ancSelList;

	return this.visit(ruleset.children[0]).then(function (selList) {
		ancSelList = this.ancestorSelectorList;
		new SelectorJoiner().join(ancSelList, selList);
		this.ancestorSelectorList = selList;

		return this.visit(ruleset.children[1]);
	}).then(function () {
		this.ancestorSelectorList = ancSelList;
	});
};

Evaluator.prototype.visit_ruleList = function (ruleList) {
	// create a new scope if necessary
	if (!ruleList.noscope) this.scope.push();

	// set a flag if ruleList is initially empty
	// so normalizer won't remove it
	if (!ruleList.children.length) ruleList.empty = true;
	return this.visit(ruleList.children).then(function () {
		if (!ruleList.noscope) this.scope.pop();

		return ruleList;
	});
};

Evaluator.prototype.visit_media = function (media) {
	var ancMqList;

	return this.visit(media.children[0]).then(function (mqList) {
		ancMqList = this.ancestorMediaQueryList;
		new MediaQueryJoiner().join(ancMqList, mqList);
		this.ancestorMediaQueryList = mqList;

		return this.visit(media.children[1]);
	}).then(function () {
		this.ancestorMediaQueryList = ancMqList;
	});
};

Evaluator.prototype.visit_range = function (range) {
	return this.visit(range.children).then(function (children) {
		var from = children[0];
		var to = children[1];

		var invalid;
		if (Node.toNumber(invalid = from) === undefined ||
			Node.toNumber(invalid = to) === undefined
		) {
			throw new RooleError(invalid.type + " cannot be used in range", invalid);
		}
	});
};

Evaluator.prototype.visit_binaryExpression = function (binExpr) {
	var op = binExpr.operator;

	switch (op) {
	case '+':
	case '-':
	case '*':
	case '/':
		if (this.retainArithmetic) {
			return this.visit(binExpr.children).then(noop);
		}
		// fall through
	case '%':
		return this.visit(binExpr.children).then(function (children) {
			return Node.perform(op, children[0], children[1]);
		});
	case '>':
	case '>=':
	case '<':
	case '<=':
		return this.visit(binExpr.children).then(function (children) {
			var left = children[0];
			var right = children[1];
			var leftVal = Node.toNumber(left);
			if (leftVal === undefined) leftVal = Node.toString(left);
			var rightVal = Node.toNumber(right);
			if (rightVal === undefined) rightVal = Node.toString(right);

			var val = op === '>' && leftVal > rightVal ||
				op === '<' && leftVal < rightVal ||
				op === '>=' && leftVal >= rightVal ||
				op === '<=' && leftVal <= rightVal;

			return {
				type: 'boolean',
				children: [val],
				loc: left.loc
			};
		});
	case 'and':
	case 'or':
		return this.visit(binExpr.children[0]).then(function (left) {
			if (
				op === 'and' && !Node.toBoolean(left) ||
				op === 'or' && Node.toBoolean(left)
			) {
				return left;
			}
			return this.visit(binExpr.children[1]);
		});
	case 'is':
	case 'isnt':
		return this.visit(binExpr.children).then(function (children) {
			var left = children[0];
			var right = children[1];

			var val = op === 'is' && Node.equal(left, right) ||
				op === 'isnt' && !Node.equal(left, right);

			return {
				type: 'boolean',
				children: [val],
				loc: left.loc,
			};
		});
	}
	return this.visit(logical.children[0]).then(function (left) {
		var op = logical.operator;
		if (
			op === 'and' && !Node.toBoolean(left) ||
			op === 'or' && Node.toBoolean(left)
		) {
			return left;
		}
		return this.visit(logical.children[1]);
	});
};

Evaluator.prototype.visit_unaryExpression = function (unaryExpr) {
	return this.visit(unaryExpr.children[0]).then(function (oprand) {
		var op = unaryExpr.operator;
		switch (op + oprand.type) {
		case '+number':
		case '+percentage':
		case '+dimension':
			return oprand;
		case '-number':
		case '-percentage':
		case '-dimension':
			var clone = Node.clone(oprand);
			clone.children[0] = -clone.children[0];
			return clone;
		case '-identifier':
			var clone = Node.clone(oprand);
			clone.children[0] = '-' + clone.children[0];
			return clone;
		}
		throw new RooleError("unsupported unary operation: " + op + oprand.type, unaryExpr);
	});
};

Evaluator.prototype.visit_assignment = function (assign) {
	var variable = assign.children[0];
	var op = assign.operator;

	if (variable.type === 'variable') {
		var name = variable.children[0];
		return this.visit(assign.children[1]).then(function (val) {
			switch (op) {
			case '?=':
				if (!this.scope.findFrame(name)) this.scope.define(name, val);
				return null;
			case '=':
				this.scope.define(name, val);
				return null;
			case ':=':
				this.scope.overwrite(name, val);
				return null;
			default:
				op = op.charAt(0);
				return this.visit(variable).then(function (origVal) {
					val = Node.perform(op, origVal, val);
					this.scope.overwrite(name, val);
					return null;
				});
			}
		});
	}

	// member expression
	var member = variable;
	var list, accessor, index;

	return this.visit(member.children[0]).then(function (l) {
		list = l;
		if (list.type !== 'list') throw new RooleError(list.type + " is not a list", list);

		return this.visit(member.children[1]);
	}).then(function (a) {
		accessor = a;

		index = Node.toNumber(accessor);
		if (index === undefined && accessor.type !== 'range') {
			throw new RooleError(accessor.type + " is not a valid index", accessor);
		}

		return this.visit(assign.children[1]);
	}).then(function (val) {
		var items = list.children;
		var len = items.length;
		if (len) len = (len + 1) / 2;

		// convert accessor to exclusive range in natural order
		var opts = index !== undefined
			? { from: index, length: len }
			: {
				from: Node.toNumber(accessor.children[0]),
				to: Node.toNumber(accessor.children[1]),
				exclusive: accessor.exclusive,
				length: len
			};
		var range = new Range(opts);

		var vals = val.type === 'list' ? val.children : [val];
		if (range.reversed) vals = vals.slice(0).reverse();

		var isAssignOp = op !== '?=' && op !== ':=' && op !== '=';

		// accessor range is on the left of the list
		if (range.to <= 0) {
			// do nothing if `$list = []; $list[-1] += 1;`
			// or `$list = 1 2; $list[-3] = [];
			if (isAssignOp || !vals.length) return null;

			var sep = Node.getJoinSeparator(val, list);

			var extras = [];
			var offset = -range.to;
			if (offset) {
				var nullNode = { type: 'null', loc: val.loc };
				for (var i = 0; i < offset; ++i) {
					extras.push(sep, nullNode);
				}
			}
			if (len) extras.push(sep);

			items.unshift.apply(items, vals.concat(extras));
			return null;
		}

		// accessor range is on the right of the list
		if (range.from >= len) {
			// do nothing if `$list = []; $list[0] += 1;`
			// // or `$list = 1 2; $list[2] = [];
			if (isAssignOp || !vals.length) return null;

			var sep = Node.getJoinSeparator(list, val);

			var extras = len ? [sep] : [];
			var offset = range.from - len;
			if (offset) {
				var nullNode = { type: 'null', loc: val.loc };
				for (var i = 0; i < offset; ++i) {
					extras.push(nullNode, sep);
				}
			}

			items.push.apply(items, extras.concat(vals));
			return null;
		}

		var from = Math.max(range.from, 0);
		var to = Math.min(range.to, len);

		if (isAssignOp) {
			// assignment operation only works on a single item
			if (to - from !== 1) return null;

			op = op.charAt(0);

			var item = items[from * 2];
			var clone = Node.clone(item, false);
			clone.loc = member.loc;
			items[from * 2] = Node.perform(op, clone, val);
			return null;
		}

		var args;
		if (from === to) {
			// do nothing if `$list = 1 2; $list[1...1] = [];`
			if (!vals.length) return null;

			from *= 2;
			var sep = items[from - 1];
			args = [from,  0].concat(vals, sep);
		} else if (vals.length) {
			from *= 2;
			to = to * 2 - 1;
			args = [from,  to - from].concat(vals);
		} else if (to === len) {
			from = Math.max(from * 2 - 1, 0);
			to = to * 2 - 1;
			args = [from, to - from];
		} else {
			from *= 2;
			to *= 2;
			args = [from, to - from];
		}
		items.splice.apply(items, args);
		return null;
	});
};

Evaluator.prototype.visit_variable = function (variable) {
	var name = variable.children[0];
	var val = this.scope.resolve(name);
	if (!val) throw new RooleError('$' + name + ' is undefined', variable);

	val = Node.clone(val, false);
	val.loc = variable.loc;
	return val;
};

Evaluator.prototype.visit_string = function (str) {
	if (str.quote === "'") return;

	return this.visit(str.children).then(function (children) {
		var val = children.map(function (child) {
			var val = Node.toString(child);
			if (val === undefined) throw new RooleError(child.type + " cannot be interpolated into String", child);

			// escape unescaped double quotes
			if (child.type === 'string') {
				val = val.replace(/\\?"/g, function(quote) {
					return quote.length === 1 ? '\\"' : quote;
				});
			}
			return val;
		}).join('');
		str.children = [val];
	});
};

Evaluator.prototype.visit_identifier = function (ident) {
	return this.visit(ident.children).then(function (children) {
		var val = children.map(function (child) {
			var val = Node.toString(child);
			if (val === undefined) throw new RooleError(child.type + " cannot be interpolated into identifier", child);
			return val;
		}).join('');
		ident.children = [val];
	});
};

Evaluator.prototype.visit_selector = function (sel) {
	var first = sel.children[0];
	var listInterp = sel.children.length === 1 && first.type === 'selectorInterpolation';
	if (listInterp) first.allowSelectorList = true;

	return this.visit(sel.children).then(function (parts) {
		if (listInterp) return parts;

		var nodes = [];
		var prevIsComb = false;

		// make sure selector interpolation not to result in
		// two consecutive combinators
		parts.forEach(function (part) {
			if (part.type !== 'combinator') {
				prevIsComb = false;
			} else if (prevIsComb) {
				nodes.pop();
			} else {
				prevIsComb = true;
			}
			nodes.push(part);
		});
		sel.children = nodes;
	});
};

Evaluator.prototype.visit_selectorInterpolation = function (interp) {
	return this.visit(interp.children).then(function (children) {
		var val = children[0];
		var str = Node.toString(val);
		if (str === undefined) {
			interp.type = 'typeSelector';
			return;
		}

		str = str.trim();
		var opts = {
			startRule: interp.allowSelectorList ? 'selectorList' : 'selector',
			loc: interp.loc
		};
		return this.eval(str, opts).then(function (node) {
			return node.children;
		}, function (err) {
			if (!interp.allowSelectorList && err.found === ',') {
				throw new RooleError("cannot interpolate selector list into complex selector", interp);
			}
			throw err;
		});
	});
};

Evaluator.prototype.eval = function (str, opts) {
	return this.visit().then(function () {
		return this.visit(parser.parse(str, opts));
	});
};

Evaluator.prototype.visit_mediaQuery = function (mq) {
	var first = mq.children[0];
	var listInterp = mq.children.length === 1 && first.type === 'mediaInterpolation';
	if (listInterp) first.allowMediaQueryList = true;

	return this.visit(mq.children).then(function (parts) {
		if (listInterp) return parts;
	});
};

Evaluator.prototype.visit_mediaInterpolation = function (interp) {
	return this.visit(interp.children).then(function (children) {
		var val = children[0];
		var str = Node.toString(val);
		if (str === undefined) {
			interp.type = 'mediaType';
			return;
		}

		str = str.trim();
		var opts = {
			startRule: interp.allowMediaQueryList ? 'mediaQueryList' : 'mediaQuery',
			loc: interp.loc
		};
		return this.eval(str, opts).then(function (mq) {
			return mq.children;
		}, function (err) {
			if (!interp.allowMediaQueryList && err.found === ',') {
				throw new RooleError("cannot interpolate media query list into complex media query", interp);
			}
			throw err;
		});
	});
};

Evaluator.prototype.visit_import = function (importNode) {
	return this.visit(importNode.children).then(function (children) {
		// ignore url()
		var url = children[0];
		if (url.type !== 'string') return;

		// ignore url starting with protocol
		var filename = url.children[0];
		if (protocolRe.test(filename)) return;

		var isCss = path.extname(filename) === '.css';

		// import file
		var promise;
		if (isCss) {
			filename = this.resolvePath(filename);
			promise = this.loadFile(filename);
		} else if (isAbsolute(filename) || prefixedPathRe.test(filename)) {
			promise = this.loadModule(filename);
		} else {
			promise = this.loadLib(filename);
		}

		return promise.then(function (file) {
			// only import once
			if (this.imported[file.name]) return null;
			this.imported[file.name] = true;

			if (isCss) {
				return parser.parse(file.content, {
					filename: file.name,
					css: true
				}).children;
			}

			var filename = this.options.filename;
			this.options.filename = file.name;
			return this.eval(file.content, { filename: file.name }).then(function (stylesheet) {
				this.options.filename = filename;
				return stylesheet.children;
			});
		}, function (err) {
			if (err.errno) throw new RooleError("cannot find module '" + filename + "'", importNode);
			throw err;
		}).then(function (rules) {
			var mqList = children[1];
			if (!mqList) return rules;

			var ruleList = {
				type: 'ruleList',
				children: rules,
				loc: mqList.loc,
			};
			var media = {
				type: 'media',
				children: [mqList, ruleList],
				loc: mqList.loc
			};
			return media;
		});
	});
};

Evaluator.prototype.loadModule = function (filename) {
	var resolved = this.resolvePath(filename);
	if (filename.slice(-1) === '/') return this.loadDir(resolved);

	return anyFirst([
		this.loadFile(resolved),
		this.loadDir(resolved)
	]);
};

Evaluator.prototype.loadDir = function (dirname) {
	var pkg = path.join(dirname, 'package.json');
	pkg = this.loadFile(pkg).then(function (file) {
		var main = JSON.parse(file.content).main;
		main = path.join(dirname, main);
		return this.loadFile(main);
	});
	var idx = path.join(dirname, 'index.roo');
	idx = this.loadFile(idx);
	var promises = [pkg, idx];

	return anyFirst(promises);
};

Evaluator.prototype.loadFile = function (filename) {
	var promise = new Promise();
	var file = { name: filename };

	var content = this.options.imports[filename];
	if(typeof content === 'string') {
		file.content = content
		return promise.fulfill(file, this);
	}

	var self = this;
	loader.load(filename, function (err, content) {
		if (err) return promise.reject(err, self);

		self.options.imports[filename] = content;
		file.content = content;
		promise.fulfill(file, self);
	});

	return promise;
};

Evaluator.prototype.loadLib = function (dirname) {
	var promises = [];

	var parts = this.resolvePath('.').split(path.sep);
	for (var i = parts.length - 1; i >= 0; --i) {
		if (parts[i] === 'node_modules') continue;

		var dirs = parts.slice(0, i + 1);
		dirs.push('node_modules');

		var libDir = dirs.join(path.sep);
		var lib = path.join(libDir, dirname);
		var promise = this.loadModule(lib);
		promises.push(promise);
	}

	return anyFirst(promises);
};

Evaluator.prototype.visit_url = function (url) {
	return this.visit(url.children).then(function (children) {
		var val = children[0];
		var filename, node;

		if (typeof val === 'string') { // url(example.com)
			filename = val;
			node = url;
		} else if (val.type === 'string') { // url('example.com')
			filename = val.children[0];
			node = val;
		} else {
			throw new RooleError(val.type + " is not allowed in url()", val);
		}

		if (protocolRe.test(filename)) return;

		node.children[0] = this.resolvePath(filename, true);
	});
};

Evaluator.prototype.resolvePath = function (filename, out) {
	if (isAbsolute(filename) || protocolRe.test(filename)) return filename;

	var base = this.options.base

	// paths starting with . or .. are relative to dir of the current file
	if (this.options.filename && prefixedPathRe.test(filename)) {
		base = path.dirname(this.options.filename);
	}

	if (!base) return filename;

	var resolved = path.resolve(base, filename);

	return out ? path.relative(this.options.out, resolved) : resolved;
};

Evaluator.prototype.visit_if = function (ifNode) {
	return this.visit(ifNode.children[0]).then(function (cond) {
		// if clause
		if (Node.toBoolean(cond)) {
			var ruleList = ifNode.children[1];
			return this.visit(ruleList).then(function (ruleList) {
				return ruleList.children;
			});
		}

		// no alternation
		var alter = ifNode.children[2];
		if (!alter) return null;

		// alternation clause
		return this.visit(alter).then(function (ruleList) {
			// alternation is else if
			if (alter.type === 'if') return ruleList;

			// alternation is else
			return ruleList.children;
		});
	});
};

Evaluator.prototype.visit_for = function (forNode) {
	var stepVal;
	return this.visit(forNode.children[2]).then(function (step) {
		// check if step is 0
		stepVal = 1;
		if (step) {
			stepVal = Node.toNumber(step);
			if (stepVal === undefined) throw new RooleError("step must be a numberic value", step);
			if (stepVal === 0) throw new RooleError("step is not allowed to be zero", step);
		}

		// evaluate the object to be iterated
		// if it's a range, do not convert it to list
		return this.visit(forNode.children[3]);
	}).then(function (list) {
		// assign value and index variable, if they exist
		var valVar = forNode.children[0];
		var idxVar = forNode.children[1];
		var valVarName = valVar.children[0];
		var idxVarName;
		if (idxVar) idxVarName = idxVar.children[0];
		var items = Node.toArray(list);

		if (!items.length) {
			if (!this.scope.resolve(valVarName)) {
				this.scope.define(valVarName, {
					type: 'null',
					loc: valVar.loc,
				});
			}
			if (idxVar && !this.scope.resolve(idxVarName)) {
				this.scope.define(idxVarName, {
					type: 'null',
					loc: idxVar.loc,
				});
			}
			return null;
		}

		// start iteration
		var ruleList = forNode.children[4];

		var rules = [];
		var promise = this.visit();

		// use reverse iteration if step < 0
		if (stepVal > 0) {
			for (var i = 0, last = items.length - 1; i <= last; i += stepVal) {
				visitRuleList(items[i], i, i === last);
			}
		} else {
			for (var i = items.length - 1; i >= 0; i += stepVal) {
				visitRuleList(items[i], i, i === 0);
			}
		}
		return promise.then(function () {
			return rules;
		});

		function visitRuleList(item, i, isLast) {
			promise = promise.then(function () {
				this.scope.define(valVarName, item);
				if (idxVar) {
					this.scope.define(idxVarName, {
						type: 'number',
						children: [i],
						loc: idxVar.loc,
					});
				}
				var clone = isLast ? ruleList : Node.clone(ruleList);
				return this.visit(clone);
			}).then(function (clone) {
				rules = rules.concat(clone.children);
			});
		}
	});
};

Evaluator.prototype.visit_function = function (func) {
	// save lexical scope
	func.scope = this.scope.clone();
	var paramList = func.children[0];
	var params = paramList.children;

	// evaluate default values for parameters
	return params.reduce(function (promise, param) {
		return promise.then(function () {
			var defaultVal = param.children[1];
			if (!defaultVal) return;

			return this.visit(defaultVal).then(function (defaultVal) {
				param.children[1] = defaultVal;
			});
		});
	}, this.visit());
};

Evaluator.prototype.visit_call = function (call) {
	return this.visit(call.children[0]).then(function (func) {
		var argList = call.children[1];

		// calc() should retain arithmetic expressions
		if (func.type === 'identifier') {
			if (func.children[0].toLowerCase() !== 'calc') {
				return this.visit(argList).then(noop);
			}

			var retainArithmetic = this.retainArithmetic;
			this.retainArithmetic = true
			return this.visit(argList).then(function () {
				this.retainArithmetic = retainArithmetic;
			});
		}

		return this.visit(argList).then(function (argList) {
			var args = argList.children;

			// builtin function
			if (func.type === 'builtin') {
				// ignore mixin
				if (call.mixin) return null;

				var throwWithLoc = function (err) {
					if (err instanceof RooleError && !err.loc) err.loc = call.loc;
					throw err;
				};

				try {
					var ret = func.children[0].apply(this, args);
				} catch (err) {
					// add location info to error object
					throwWithLoc(err);
				}
				if (ret && typeof ret.then === 'function') {
					return ret.then(function (ret) {
						return Node.toNode(ret, call.loc);
					}, throwWithLoc);
				}
				return Node.toNode(ret, call.loc);
			}

			// invalid call
			if (func.type !== 'function') throw new RooleError(func.type + " is not a function", func);

			// create local scope
			var scope = this.scope;
			this.scope = func.scope;
			this.scope.push();

			// create $arguments variable
			var list = Node.toListNode(argList);
			this.scope.define('arguments', list);

			// assign arguments to parameters
			var paramList = func.children[0];
			var params = paramList.children;
			params.forEach(function (param, i) {
				var ident = param.children[0];
				var name = ident.children[0];
				var val;
				if (param.type === 'restParameter') {
					val = Node.toListNode({
						type: 'argumentList',
						children: args.slice(i),
						loc: argList.loc,
					});
				} else if (i < args.length) {
					val = args[i];
				} else {
					val = param.children[1];
					if (!val) val = { type: 'null', loc: argList.loc };
				}
				this.scope.define(name, val);
			}, this);

			// call function as mixin or regular function
			var context = this.context;
			var ruleList = func.children[1];
			// scope is already created manually, so don't create it again
			ruleList.noscope = true;

			var clone = Node.clone(ruleList);
			var ret;
			if (call.mixin) {
				this.context = 'mixin';
				ret = this.visit(clone).then(function (ruleList) {
					return ruleList.children;
				});
			} else {
				this.context = 'call';
				var returned;
				ret = this.visit(clone).then(null, function (ret) {
					if (ret instanceof Error) throw ret;
					returned = ret;
				}).then(function () {
					return returned || { type: 'null', loc: call.loc };
				});
			}
			return ret.then(function (node) {
				this.scope.pop();
				this.scope = scope;
				this.context = context;
				return node;
			});
		});
	});
};

Evaluator.prototype.visit_return = function (ret) {
	if (!this.context) throw new RooleError("return is only allowed inside function", ret);
	if (this.context !== 'call') return null;
	throw this.visit(ret.children[0]);
};

Evaluator.prototype.visit_mixin = function (mixin) {
	var val = mixin.children[0];

	switch (val.type) {
	case 'call':
		val.mixin = true;
		return this.visit(val);
	case 'selectorList':
		return this.visit(val).then(noop);
	default:
		throw new RooleError("Cannot mixin " + val.type, val);
	}
};

Evaluator.prototype.visit_classSelector = function (sel) {
	return this.visit(sel.children).then(function (children) {
		var ident = children[0];
		if (ident.type !== 'identifier') throw new RooleError(ident.type + " is not allowed in class selector", ident);

		if (!this.moduleName) return;
		ident.children[0] = this.moduleName + ident.children[0];
	});
};

Evaluator.prototype.visit_block = function (block) {
	return this.visit(block.children[0]).then(function (ruleList) {
		return ruleList.children;
	});
};

Evaluator.prototype.visit_member = function(member) {
	var list;
	return this.visit(member.children[0]).then(function (l) {
		list = l;
		switch (list.type) {
		case 'null':
			throw new RooleError("Cannot read item of null", member);
		case 'list':
		case 'range':
			break;
		default:
			return { type: 'null', loc: member.loc };
		}

		return this.visit(member.children[1]);
	}).then(function (accessor) {
		var index = Node.toNumber(accessor);

		if (index === undefined && accessor.type !== 'range') {
			return { type: 'null', loc: member.loc };
		}

		var items = Node.toArray(list);
		var len = items.length;
		if (index !== undefined) {
			if (index < 0) index += len;
			if (0 <= index && index < len) {
				var item = items[index];
				var clone = Node.clone(item, false);
				clone.loc = member.loc
				return clone;
			}
			return { type: 'null', loc: member.loc };
		}

		var range = new Range({
			from: Node.toNumber(accessor.children[0]),
			to: Node.toNumber(accessor.children[1]),
			exclusive: accessor.exclusive,
			length: len
		});

		var from = Math.max(range.from, 0);
		var to = Math.min(range.to, len);

		if (from === to || to <= 0 || from >= len) {
			items = [];
		} else {
			if (list.type === 'range') list = Node.toListNode(list);
			items = list.children.slice(from * 2, to * 2 - 1);
			if (range.reversed) items.reverse();
		}

		return {
			type: 'list',
			children: items,
			loc: member.loc
		};
	});
};

Evaluator.prototype.visit_statement = function (stmt) {
	return this.visit(stmt.children).then(function () {
		return null;
	});
};

Evaluator.prototype.visit_unit = function (unit) {
	return this.visit(unit.children[0]).then(function (val) {
		var num = Node.toNumber(val);
		if (num === undefined) throw new RooleError(val.type + " is not numbric", val);
		return unit.unit === '%' ? {
			type: 'percentage',
			children: [num],
			loc: unit.loc
		} : {
			type: 'dimension',
			children: [num, unit.unit],
			loc: unit.loc
		};
	});
};