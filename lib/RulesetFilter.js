/**
 * Ruleset Filter
 *
 * Find ruleset node matching the selector
 */
var Node = require('roole-node');
var Visitor = require('tree-visitor');
var stop = {};

module.exports = RulesetFilter;

function RulesetFilter(options) {
	var stopNode = options.stop;
	this['visit_' + stopNode.type] = function (node) {
		if (node === stopNode) throw stop;
	};

	if (options.visitMedia) this.visit_media = this.visit_ruleList;
}

RulesetFilter.prototype = new Visitor();

RulesetFilter.prototype.filter = function (nodes, selList) {
	this.rulesets = [];
	this.selectorList = selList;

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