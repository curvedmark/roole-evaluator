/**
 * RulesetExtender
 *
 * Extend selectors in rulesets with the selector
 */
var Node = require('roole-node');
var Visitor = require('tree-visitor');
var SelectorJoiner = require('./SelectorJoiner');
var stop = {};

module.exports = RulesetExtender;

function RulesetExtender(options) {
	this.options = options;

	var stopNode = options.stop;
	this['visit_' + stopNode.type] = function (node) {
		if (node === stopNode) throw stop;
	};
}

RulesetExtender.prototype = new Visitor();

RulesetExtender.prototype.extend = function (node, selList) {
	this.selectorList = selList;

	try {
		this.visit(node);
	} catch (err) {
		if (err !== stop) throw err;
	}
};

RulesetExtender.prototype.visit_media =
RulesetExtender.prototype.visit_ruleList = function (node) {
	this.visit(node.children);
};

RulesetExtender.prototype.visit_ruleset = function (ruleset) {
	var ancSelList = this.ancestorSelectorList;
	this.visit(ruleset.children);
	this.ancestorSelectorList = ancSelList;
};

RulesetExtender.prototype.visit_selectorList = function (selList) {
	// append selectors to matched rulesets
	// then flatten nested rulesets with the
	// appended selectors being the ancestor selectors
	var newSelList;
	if (!this.ancestorSelectorList) {
		newSelList = this.selectorList;
	} else {
		newSelList = Node.clone(selList.original || selList);
		new SelectorJoiner().join(this.ancestorSelectorList, newSelList);
	}
	selList.children = selList.children.concat(newSelList.children);

	// when @extend is inside a void node, the extending selectors should
	// not be appended to matched rulesets
	if (this.options.record) {
		if (!selList.extended) selList.extended = newSelList.children
		else selList.extended = selList.extended.concat(newSelList.children);
	}

	// if a module's class selector is being extended
	// nested rulesets should not be extended
	if (selList.isModule) throw stop;

	this.ancestorSelectorList = newSelList;
};