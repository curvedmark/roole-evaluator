var RooleError = require('roole-error');
var Node = require('roole-node');
var Range = require('natural-range');
var intersperse = require('intersperse');
var path = require('path');
var urlRe = /^((?:\w+:)?\/\/[^\/]+)(\/[^?#]*|)((?:\?[^#]*)?(?:#.*)?)/;

/**
 * $__dirname
 *
 * Resolve to the relative path between the current dir and the out dir
 */
exports.__dirname = {
	type: 'builtinVariable',
	children: [function (variable, options) {
		var filename = variable.loc.filename;
		var result = urlRe.exec(filename);
		var head;
		if (result) {
			head = result[1];
			filename = result[2] || '/';
		} else {
			head = '';
		}
		var dirname = filename.slice(-1) === path.sep
			? filename
			: path.dirname(filename);

		var out = options.out;
		result = urlRe.exec(out);
		var relative;
		if (result) {
			if (result[1] === head) {
				out = result[2] || '/';
				relative = path.relative(out, dirname);
			} else {
				relative = head + dirname;
			}
		} else {
			relative = path.relative(out, dirname)
		}

		return {
			type: 'string',
			quote: '"',
			children: [relative],
			loc: variable.loc
		};
	}]
};

/**
 * $len($obj)
 *
 * Return the length of an object
 *
 * For lists, it the number of their non-separator items
 * For others, it is 1
 */
exports.len = {
	type: 'builtinFunction',
	children: [function (call) {
		var args = call.children[1].children;
		if (!args.length) return { type: 'null', loc: call.loc };

		var arg = args[0];
		var length;
		if (arg.type === 'range') {
			var range = new Range({
				from: Node.toNumber(arg.children[0]),
				to: Node.toNumber(arg.children[1]),
				exclusive: arg.exclusive
			});
			length = range.to - range.from;
		} else if (arg.type !== 'list') {
			length = 1
		} else if (!arg.children.length) {
			length = 0;
		} else {
			length = (arg.children.length + 1) / 2;
		}

		return {
			type: 'number',
			children: [length],
			loc: call.loc
		};
	}]
};

/**
 * $opp($val)
 *
 * Return the opposite value of a string or an identifier denoting a position
 *
 * right <-> left
 * top <-> bottom
 *
 * Other values stay the same
 */
exports.opp = {
	type: 'builtinFunction',
	children: [function (call) {
		var args = call.children[1].children;
		if (!args.length) return { type: 'null', loc: call.loc };

		return Node.toOppositeNode(args[0]);
	}]
};

/**
 * $unit($val, [$str])
 *
 * Return a string representing the unit of a value
 *
 * If $str is passed, set the value with unit denoted by a string or an identifier
 */
exports.unit = {
	type: 'builtinFunction',
	children: [function (call) {
		var args = call.children[1].children;
		if (!args.length) return { type: 'null', loc: call.loc };

		var num = args[0];
		var val = Node.toNumber(num);
		if (val === undefined) return { type: 'null', loc: call.loc };

		if (args.length === 1) {
			switch (num.type) {
			case 'number':
				return {
					type: 'string',
					quote: '"',
					children: [''],
					loc: call.loc,
				};
			case 'percentage':
				return {
					type: 'string',
					quote: '"',
					children: ['%'],
					loc: call.loc,
				};
			case 'dimension':
				return {
					type: 'string',
					quote: '"',
					children: [num.children[1]],
					loc: call.loc,
				};
			}
		}

		var unit = args[1];
		switch (unit.type) {
		case 'number':
		case 'null':
			return {
				type: 'number',
				children: [val],
				loc: call.loc
			};
		case 'percentage':
			return {
				type: 'percentage',
				children: [val],
				loc: call.loc
			};
		case 'dimension':
			return {
				type: 'dimension',
				children: [val, unit.children[1]],
				loc: call.loc
			};
		case 'identifier':
			return {
				type: 'dimension',
				children: [val, unit.children[0]],
				loc: call.loc
			};
		case 'string':
			var unitVal = unit.children[0];
			if (!unitVal) {
				return {
					type: 'number',
					children: [val],
					loc: call.loc
				};
			}

			if (unitVal === '%') {
				return {
					type: 'percentage',
					children: [val],
					loc: call.loc
				};
			}

			return {
				type: 'dimension',
				children: [val, unitVal],
				loc: call.loc
			};
		default:
			return { type: 'null', loc: call.loc };
		}
	}]
};


/**
 * $list($obj, [$sep])
 *
 * Convert an object into a list.
 *
 * If `$sep` is passed, items in the list are separated by it.
 */
exports.list = {
	type: 'builtinFunction',
	children: [function (call) {
		var args = call.children[1].children;
		if (!args.length) return { type: 'list', children: [], loc: call.loc };

		var list = args[0];
		list = Node.toListNode(list);

		if (args.length <= 1) return list;

		var sep = args[1];
		if (sep.type !== 'string') return list;
		switch(sep.children[0]) {
		case ' ':
		case '/':
		case ',':
			sep = {
				type: 'separator',
				children: [sep.children[0]],
				loc: sep.loc
			};
			break;
		default:
			return list;
		}
		var items = Node.toArray(list);
		return {
			type: 'list',
			children: intersperse(items, sep),
			loc: list.loc
		};
	}]
};

/**
 * $push($list, ...$items)
 *
 * Push items to the list
 */
exports.push = {
	type: 'builtinFunction',
	children: [function (call) {
		var args = call.children[1].children;
		if (!args.length) return { type: 'null', loc: call.loc };
		if (args.length === 1) return args[0];

		var list = args.shift();
		if (list.type !== 'list') throw new RooleError(list.type + ' is not a list', list);

		var first = args[0];
		var sep = Node.getJoinSeparator(list, first);
		var items = list.children;

		items.push(sep, first);
		for (var i = 1, len = args.length; i < len; ++i) {
			var arg = args[i];
			sep = Node.getJoinSeparator(list, arg);
			items.push(sep, arg)
		}

		return list;
	}]
};

/**
 * $unshift($list, ...$items)
 *
 * Unshift items to the list
 */
exports.unshift = {
	type: 'builtinFunction',
	children: [function (call) {
		var args = call.children[1].children;
		if (!args.length) return { type: 'null', loc: call.loc };
		if (args.length === 1) return args[0];

		var list = args.shift();
		if (list.type !== 'list') throw new RooleError(list.type + ' is not a list', list);

		var last = args[args.length - 1];
		var sep = Node.getJoinSeparator(last, list);
		var items = list.children;

		items.unshift(last, sep);
		for (var i = args.length - 2; i >= 0; --i) {
			var arg = args[i];
			sep = Node.getJoinSeparator(arg, list);
			items.unshift(arg, sep);
		}

		return list;
	}]
};

/**
 * $pop($list)
 *
 * Pop an item from the list
 */
exports.pop = {
	type: 'builtinFunction',
	children: [function (call) {
		var args = call.children[1].children;
		if (!args.length) return { type: 'null', loc: call.loc };

		var list = args.shift();
		if (list.type !== 'list') throw new RooleError(list.type + ' is not a list', list);

		if (!list.children.length) return { type: 'null', loc: call.loc };
		if (list.children.length === 1) return list.children.pop();

		var item = list.children.pop();
		// remove separator;
		list.children.pop()

		return item;
	}]
};


/**
 * $shift($list)
 *
 * Shift an item from the list
 */
exports.shift = {
	type: 'builtinFunction',
	children: [function (call) {
		var args = call.children[1].children;
		if (!args.length) return { type: 'null', loc: call.loc };

		var list = args.shift();
		if (list.type !== 'list') throw new RooleError(list.type + ' is not a list', list);

		if (!list.children.length) return { type: 'null', loc: call.loc };
		if (list.children.length === 1) return list.children.shift();

		var item = list.children.shift();
		// remove separator;
		list.children.shift()

		return item;
	}]
};