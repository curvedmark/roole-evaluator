/**
 * Reevaluator
 *
 * Second stage of evaluation.
 * Evaluate constructs that interact with rules coming after them.
 */
var Transformer = require('tree-transformer');
var Node = require('roole-node');
var RulesetFilter = require('./RulesetFilter');
var RulesetFlattener = require('./RulesetFlattener');

module.exports = Reevaluator

function Reevaluator() {}

Reevaluator.prototype = new Transformer();

Reevaluator.prototype.reevaluate = function (node) {
	return this.visit(this.ast = node);
};

Reevaluator.prototype.visit_stylesheet =
Reevaluator.prototype.visit_void =
Reevaluator.prototype.visit_media =
Reevaluator.prototype.visit_ruleList = function (node) {
	this.visit(node.children);
};

Reevaluator.prototype.visit_ruleset = function (ruleset) {
	var ancSelList = this.ancestorSelectorList;
	this.ancestorSelectorList = ruleset.children[0];
	this.visit(ruleset.children[1]);
	this.ancestorSelectorList = ancSelList;
};

Reevaluator.prototype.visit_mixin = function (mixin) {
	var selList = mixin.children[0];
	var rulesets = new RulesetFilter().filter(this.ast, selList);

	var rules = [];
	rulesets.forEach(function (ruleset) {
		var ruleList = ruleset.children[1];
		rules = rules.concat(ruleList.children);
	});
	rules = Node.clone(rules);

	new RulesetFlattener().flatten(rules, this.ancestorSelectorList);

	return rules;
};