/**
 * RulesetFlattener
 *
 * Extend selectors in rulesets with the selector
 */
var Node = require('roole-node');
var Visitor = require('tree-visitor');
var SelectorJoiner = require('./SelectorJoiner');

module.exports = RulesetFlattener;

function RulesetFlattener() {}

RulesetFlattener.prototype = new Visitor();

RulesetFlattener.prototype.flatten = function (node, selList) {
	this.ancestorSelectorList = selList;
	this.visit(node);
};

RulesetFlattener.prototype.visit_void =
RulesetFlattener.prototype.visit_media =
RulesetFlattener.prototype.visit_ruleList = function (node) {
	this.visit(node.children);
};

RulesetFlattener.prototype.visit_ruleset = function (ruleset) {
	var ancSelList = this.ancestorSelectorList;
	var selList = ruleset.children[0];
	selList = Node.clone(selList.original || selList);
	new SelectorJoiner().join(this.ancestorSelectorList, selList);

	this.ancestorSelectorList = selList;
	this.visit(ruleset.children);
	this.ancestorSelectorList = ancSelList;
};