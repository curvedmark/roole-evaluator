/**
 * Ruleset Filter
 *
 * Find ruleset node matching the selector
 */
var Node = require('roole-node');
var Visitor = require('tree-visitor');

module.exports = RulesetFilter;

function RulesetFilter(options) {}

RulesetFilter.prototype = new Visitor();

RulesetFilter.prototype.filter = function (nodes, selList) {
	this.rulesets = [];
	this.selectorList = selList;

	this.visit(nodes);

	return this.rulesets;
}

RulesetFilter.prototype.visit_stylesheet =
RulesetFilter.prototype.visit_void =
RulesetFilter.prototype.visit_ruleList = function (node) {
	this.visit(node.children);
};

RulesetFilter.prototype.visit_ruleset = function(ruleset) {
	var selList = ruleset.children[0];
	var matched = selList.children.some(function(target) {
		return this.selectorList.children.some(function (sel) {
			if (Node.equal(target, sel)) {
				this.rulesets.push(ruleset);
				return true;
			}
		}, this);
	}, this);

	if (!matched) this.visit(ruleset.children[1]);
};