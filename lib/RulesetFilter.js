/**
 * Ruleset Filter
 *
 * Find ruleset node matching the selector
 */
var Node = require('roole-node');
var Visitor = require('tree-visitor');
var stop = {};

module.exports = RulesetFilter;

function RulesetFilter() {}

RulesetFilter.prototype = new Visitor();

RulesetFilter.prototype.filter = function (nodes, sel) {
	this.selector = sel;
	this.rulesets = [];

	try {
		this.visit(nodes);
	} catch (err) {
		if (err !== stop) throw err;
	}

	return this.rulesets;
}


RulesetFilter.prototype.visit_void =
RulesetFilter.prototype.visit_ruleList = function (node) {
	this.visit(node.children);
};

RulesetFilter.prototype.visit_extend = function(extend) {
    if (extend.current) throw stop;
};

RulesetFilter.prototype.visit_ruleset = function(ruleset) {
	var selList = ruleset.children[0];
	var matched = selList.children.some(function(sel) {
		if (Node.equal(sel, this.selector)) this.rulesets.push(ruleset);
	}, this);

	if (matched) return true;
	this.visit(ruleset.children[1]);
};