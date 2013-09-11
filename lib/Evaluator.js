var TransformerAsync = require('tree-transformer-async');
var RooleError = require('roole-error');
var Node = require('roole-node');
var parser = require('roole-parser');
var Promise = require('promise-now');
var anyFirstPromise = require('promise-any-first');
var Range = require('natural-range');
var Path = require('path-extras');
var loader = require('floader');
var builtin = require('roole-builtin');

var Scope = require('./Scope');
var Normalizer = require('./Normalizer');
var SelectorJoiner = require('./SelectorJoiner');
var RulesetFilter = require('./RulesetFilter');
var RulesetExtender = require('./RulesetExtender');
var MediaQueryJoiner = require('./MediaQueryJoiner');
var MediaFilter = require('./MediaFilter');

var protocolRe = /^(?:[^\/:]+:)?\/\/|^[^\/:]+:/;
var moduleRe = /^\.\/|^\.$|^\.\.\/|^\.\.$|^\//;
var noop = function () {};

module.exports = Evaluator;

function Evaluator(options) {
	if (!options) options = {};
	if (!options.imports) options.imports = {};

	this.options = options;
	this.imported = {};

	this.scope = new Scope([builtin, {}]);
}

Evaluator.builtin = builtin;

Evaluator.prototype = new TransformerAsync();

Evaluator.prototype.evaluate = function (node) {
	return this.visit(node).then(function (node) {
		return new Normalizer(this.options).normalize(node);
	});
};

Evaluator.prototype.visit_node = function (node) {
	if (!node.children) return;

	return this.visit(node.children).then(function () {
		return node;
	});
};

Evaluator.prototype.visit_stylesheet = function (stylesheet) {
	var ancBoundary = this.ancestorBoundary;
	this.ancestorBoundary = stylesheet;
	return this.visit(stylesheet.children).then(function () {
		this.ancestorBoundary = ancBoundary;
		return stylesheet;
	});
};

Evaluator.prototype.visit_ruleset = function (ruleset) {
	var ancSelList;

	return this.visit(ruleset.children[0]).then(function (selList) {
		// flatten selectors
		ancSelList = this.ancestorSelectorList;

		var clone = Node.clone(selList);
		selList.original = clone;
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

Evaluator.prototype.visit_extend = function (extend) {
	return this.visit(extend.children).then(function (children) {
		var nodes = this.ancestorBoundary.children;
		// set a flag on this node
		// so filters won't pass this node when visiting nodes
		extend.current = true

		// find medias with the same ancestor media query
		if (this.ancestorMediaQueryList) {
			var medias = new MediaFilter().filter(nodes, this.ancestorMediaQueryList);
			nodes = [];
			medias.forEach(function(media) {
				nodes = nodes.concat(media.children);
			});
		}

		// find rulesets with the same selector
		var rulesets = [];
		var selList = children[0];
		selList.children.forEach(function(sel) {
			var filtered = new RulesetFilter().filter(nodes, sel);
			rulesets = rulesets.concat(filtered);
		});

		// extend rulesets with ancestor selector
		new RulesetExtender({
			record: !this.ancestorVoid
		}).extend(rulesets, this.ancestorSelectorList);

		delete extend.current;

		return null;
	});
};

Evaluator.prototype.visit_void = function (voidNode) {
	var ancVoid = this.ancestorVoid;
	this.ancestorVoid = voidNode;

	var ancBoundary = this.ancestorBoundary;
	this.ancestorBoundary = voidNode;

	return this.visit(voidNode.children).then(function () {
		this.ancestorVoid = ancVoid;
		this.ancestorBoundary = ancBoundary;
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
				if (!this.scope.resolve(name)) this.scope.define(name, val);
				return null;
			case '=':
				this.scope.define(name, val);
				return null;
			default:
				op = op.charAt(0);
				return this.visit(variable).then(function (origVal) {
					val = Node.perform(op, origVal, val);
					this.scope.define(name, val);
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

		var isAssignOp = op !== '?=' && op !== '=';

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
			if (val === undefined) throw new RooleError(child.type + " is not allowed to be interpolated in String", child);

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
			if (val === undefined) throw new RooleError(child.type + " is not allowed to be interpolated in Identifier", child);
			return val;
		}).join('');
		ident.children = [val];
	});
};

Evaluator.prototype.visit_selector = function (sel) {
	return this.visit(sel.children).then(function (children) {
		var nodes = [];
		var prevIsComb = false;

		// make sure selector interpolation not to result in
		// two consecutive combinators
		children.forEach(function (child) {
			if (child.type !== 'combinator') {
				prevIsComb = false;
			} else if (prevIsComb) {
				nodes.pop();
			} else {
				prevIsComb = true;
			}
			nodes.push(child);
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
			filename: interp.filename,
			startRule: 'selector',
			loc: val.loc
		};
		return this.eval(str, opts).then(function (sel) {
			return sel.children;
		});
	});
};

Evaluator.prototype.eval = function (str, opts) {
	var node = parser.parse(str, opts);
	return this.visit(node);
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
			filename: interp.filename,
			startRule: 'mediaQuery',
			loc: val.loc
		};
		return this.eval(str, opts).then(function (mq) {
			return mq.children;
		});
	});
};

Evaluator.prototype.visit_import = function (importNode) {
	return this.visit(importNode.children).then(function (children) {
		// ignore @import containing media query
		var mqList = children[1];
		if (mqList) return;

		// ignore url()
		var url = children[0];
		if (url.type !== 'string') return;

		// ignore url starting with protocol
		var path = url.children[0];
		if (protocolRe.test(path)) return;

		// ignore url ending with .css
		var dirname = Path.foldername(importNode.loc.filename);
		if (Path.extname(path) === '.css') {
			if (Path.isAbsolute(path)) return;

			var filename = Path.resolve(dirname, path);
			url.children[0] = Path.relative(this.options.out, filename);
			return;
		}

		// import file
		var promise = moduleRe.test(path)
			? this.importModule(path, dirname)
			: this.importLib(path, dirname);

		return promise.then(function (file) {
			// file already imported
			if (file === null) return null;

			// eval the imported file
			var opts = { filename: file.name };
			return this.eval(file.content, opts).then(function (stylesheet) {
				return stylesheet.children;
			});
		}, function (err) {
			if (err.errno === 34) throw new RooleError("Cannot find module '" + path + "'", importNode);
			throw err;
		})
	});
};

Evaluator.prototype.importModule = function (path, dirname) {
	if (Path.isDir(path)) return this.importDir(path, dirname);

	var extReq = Path.extname(path) ? path : path + '.roo';
	return anyFirstPromise([
		this.importFile(extReq, dirname),
		this.importDir(path, dirname)
	]);
};

Evaluator.prototype.importDir = function (path, dirname) {
	dirname = Path.resolve(dirname, path);
	var pkg = this.importFile('package.json', dirname).then(function (file) {
		var main = JSON.parse(file.content).main;
		return this.importFile(main, dirname);
	});
	var idx = this.importFile('index.roo', dirname);
	var promises = [pkg, idx];

	return anyFirstPromise(promises);
};

Evaluator.prototype.importFile = function (path, dirname) {
	var filename = Path.resolve(dirname, path);

	// only import once
	if (this.imported[filename]) return this.visit(null);

	var content = this.options.imports[filename];
	promise = typeof content === 'string'
		? this.visit(content)
		: this.load(filename);

	return promise.then(function (content) {
		this.options.imports[filename] = content;
		this.imported[filename] = true;

		return {
			name: filename,
			content: content
		};
	});
};

Evaluator.prototype.importLib = function (path, dirname) {
	var promises = [];

	dirname = Path.resolve(dirname);
	var parts = dirname.split(Path.sep);

	for (var i = parts.length - 1; i >= 0; --i) {
		if (parts[i] === 'node_modules') continue;

		var dirs = parts.slice(0, i + 1);
		dirs.push('node_modules');
		dirname = dirs.join(Path.sep);

		var promise = this.importModule(path, dirname);
		promises.push(promise);
	}

	return anyFirstPromise(promises);
};

Evaluator.prototype.load = function (filename) {
	var promise = new Promise();
	var self = this;

	loader.load(filename, function (err, content) {
		if (err) return promise.reject(err, self);
		promise.fulfill(content, self);
	});

	return promise;
};

Evaluator.prototype.visit_url = function (url) {
	return this.visit(url.children).then(function (children) {
		var val = children[0];
		var addr, node;

		if (typeof val === 'string') {
			addr = val;
			node = url;
		} else if (val.type === 'string') {
			addr = val.children[0];
			node = val;
		} else {
			throw new RooleError(val.type + " is not allowed in url()", val);
		}

		if (protocolRe.test(addr)) return;
		if (Path.isAbsolute(addr)) return;

		var dirname = Path.foldername(url.loc.filename);
		var filename = Path.resolve(dirname, addr);
		node.children[0] = Path.relative(this.options.out, filename);
	});
};

Evaluator.prototype.visit_if = function (ifNode) {
	return this.visit(ifNode.children[0]).then(function (cond) {
		// if clause
		if (Node.toBoolean(cond)) {
			var ruleList = ifNode.children[1];
			ruleList.noscope = true;
			return this.visit(ruleList).then(function (ruleList) {
				return ruleList.children;
			});
		}

		// no alternation
		var alter = ifNode.children[2];
		if (!alter) return null;

		// alternation clause
		if (alter.type === 'ruleList') alter.noscope = true;
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
		ruleList.noscope = true;

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
			// builtin function
			if (func.type === 'builtin') {
				// ignore mixin
				if (call.mixin) return null;
				return func.children[0](call, this.options);
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
			var args = argList.children;
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
	if (!this.context) throw new RooleError('@return is only allowed inside @function', ret);
	if (this.context === 'call') throw this.visit(ret.children[0]);
	return null;
};

Evaluator.prototype.visit_module = function (mod) {
	var nameVal;
	var ancModName = this.ancestorModuleName || '';

	return this.visit(mod.children[0]).then(function (name) {
		nameVal = Node.toString(name);
		if (nameVal === undefined) throw new RooleError(name.type + " can not be used as a module name" , name);
		return this.visit(mod.children[1]);
	}).then(function (sep) {
		var sepVal = sep ? Node.toString(sep) : '-';
		if (sepVal === undefined) throw new RooleError(sep.type + " can not be used as a module name separator" , sep);
		this.ancestorModuleName = ancModName + nameVal + sepVal;
		return this.visit(mod.children[2]);
	}).then(function (ruleList) {
		this.ancestorModuleName = ancModName;
		return ruleList.children;
	});
};

Evaluator.prototype.visit_classSelector = function (sel) {
	return this.visit(sel.children).then(function (children) {
		var ident = children[0];
		if (ident.type !== 'identifier') throw new RooleError(ident.type + " is not allowed in class selector", ident);

		if (!this.ancestorModuleName) return;
		ident.children[0] = this.ancestorModuleName + ident.children[0];
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