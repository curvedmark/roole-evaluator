var Node = require('roole-node');
var Range = require('natural-range');
var intersperse = require('intersperse');
var path = require('path');
var urlRe = /^((?:\w+:)?\/\/[^\/]+)(\/[^?#]*|)((?:\?[^#]*)?(?:#.*)?)/;

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

exports.opp = {
	type: 'builtinFunction',
	children: [function (call) {
		var args = call.children[1].children;
		if (!args.length) return { type: 'null', loc: call.loc };

		return Node.toOppositeNode(args[0]);
	}]
};

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