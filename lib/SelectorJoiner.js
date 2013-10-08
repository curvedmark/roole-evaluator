/**
 * SelectorJoiner
 *
 * Flatten nested selectors
 */
var RooleError = require('roole-error');
var Node = require('roole-node');
var Transformer = require('tree-transformer');

module.exports = SelectorJoiner;

function SelectorJoiner() {}

SelectorJoiner.prototype = new Transformer();

SelectorJoiner.prototype.join = function (ancSelList, selList) {
	this.ancestorSelectorList = ancSelList;
	return this.visit(selList);
};

SelectorJoiner.prototype.visit_selectorList = function (selList) {
	if (!this.ancestorSelectorList) {
		this.visit(selList.children);
		return selList;
	}

	// keep a record of original selector list
	// used when extending rulesets
	if (!selList.original) selList.original = Node.clone(selList);

	// join each selector in the selector list to each ancestor selector
	var children = [];
	var ancSels = this.ancestorSelectorList.children;
	var last = ancSels.length - 1;
	ancSels.forEach(function (ancSel, i) {
		this.ancestorSelector = ancSel;

		var clone = i === last ? selList : Node.clone(selList);
		children = children.concat(this.visit(clone.children));
	}, this);
	selList.children = children;
};

SelectorJoiner.prototype.visit_selector = function (sel) {
	this.visit(sel.children);

	if (this.hasAmpersandSelector) {
		this.hasAmpersandSelector = false;
		return;
	}

	// if selector doesn't contain an & selector
	// join selector to ancestor selector
	var first = sel.children[0];
	if (first.type === 'combinator') {
		if (!this.ancestorSelector) throw new RooleError('top-level selector cannot start with a combinator', first);
		sel.children = this.ancestorSelector.children.concat(sel.children);
	} else if (this.ancestorSelector) {
		var comb = {
			type: 'combinator',
			children: [' '],
			loc: sel.loc,
		};
		sel.children = this.ancestorSelector.children.concat(comb, sel.children);
	}
};

SelectorJoiner.prototype.visit_ampersandSelector = function (sel) {
	if (!this.ancestorSelector) throw new RooleError('top-level & selector is not allowed', sel);

	this.hasAmpersandSelector = true;
	var val = sel.children[0];
	if (!val) return this.ancestorSelector.children;

	var ancSels = this.ancestorSelector.children;
	var last = ancSels[ancSels.length - 1];
	switch (last.type) {
	case 'classSelector':
	case 'hashSelector':
	case 'typeSelector':
		break;
	default:
		throw new RooleError('cannot append string to ' + last.type, sel);
	}

	// flatten selectors like `.class { $-foo {} }`
	var sel = Node.clone(last);
	var id = sel.children[0];
	id.children[0] += val.children[0];
	ancSels = ancSels.slice(0, -1);
	ancSels.push(sel);
	return ancSels;
};