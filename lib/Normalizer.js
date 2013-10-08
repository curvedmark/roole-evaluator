/**
 * Normalizer
 *
 * Remove unextended rulesets inside voids
 * Flatten nested rulesets and medias
 * Flatten nested lists
 * Convert single-item lists to single items
 * Convert ranges to lists
 */
var RooleError = require('roole-error');
var Node = require('roole-node');
var Transformer = require('tree-transformer');

module.exports = Normalizer;

function Normalizer() {}

Normalizer.prototype = new Transformer();

Normalizer.prototype.normalize = function (node) {
	return this.visit(node);
};

Normalizer.prototype.visit_node = function (node) {
	if (node.children) this.visit(node.children);
};

Normalizer.prototype.visit_ruleset = function (ruleset) {
	var selList = ruleset.children[0];
	var ancSelList = this.ancestorSelectorList;
	this.ancestorSelectorList = selList;

	var ruleList = ruleset.children[1];
	var children = this.visit(ruleList).children;

	this.ancestorSelectorList = ancSelList;

	// flatten rules nested in ruleset
	var props = [];
	var rules = [];
	children.forEach(function (child) {
		if (child.type === 'property') props.push(child);
		else rules.push(child);
	});

	// remove empty ruleset unless it was initally empty
	if (!props.length) {
		if (ruleList.empty) return;
		return rules;
	}

	// set a level property indicating how many levels it
	// should be indented
	rules.forEach(function (rule) {
		if (rule.level === undefined) rule.level = 0;
		++rule.level;
	});

	// make this ruleset contain only properies
	ruleList = {
		type: 'ruleList',
		children: props,
		loc: props[0].loc,
	};
	ruleset.children[1] = ruleList;

	// append flattened rules bellow this ruleset
	rules.unshift(ruleset);
	return rules;
};

Normalizer.prototype.visit_void = function () {
	return null;
};

Normalizer.prototype.visit_media = function (media) {
	// collect properties and rulesets in this media
	var ruleList = media.children[1];
	var children = this.visit(ruleList).children;

	var props = [];
	var rulesets = [];
	var rules = [];
	children.forEach(function (child) {
		if (child.type === 'property') props.push(child);
		else if (child.type === 'ruleset') rulesets.push(child);
		else rules.push(child);
	});

	var newRuleList;
	// create ruleset for media containing properties
	if (props.length) {
		if (!this.ancestorSelectorList) throw new RooleError('top-level @media can not directly contain properties', media);

		newRuleList = {
			type: 'ruleList',
			children: props,
			loc: props[0].loc
		};
	}
	// create empty ruleset for empty media contained in a ruleset
	else if (ruleList.empty && this.ancestorSelectorList) {
		newRuleList = {
			type: 'ruleList',
			children: [],
			loc: ruleList.loc
		};
	}
	if (newRuleList) {
		var ruleset = {
			type: 'ruleset',
			children: [this.ancestorSelectorList, newRuleList],
			loc: media.loc
		};
		rulesets.unshift(ruleset);
	}

	// remove empty media unless it was initally empty
	if (!rulesets.length) {
		if (ruleList.empty) return;
		return rules;
	}

	// set a level property indicating how many levels it
	// should be indented in the css
	// for rulesets, this level is relative to the current media
	rules.forEach(function (rule) {
		if (rule.level === undefined) rule.level = 0;

		// first-level nested media should have a level of 1
		// since media can not be nested in css
		if (rule.type === 'media' && !rule.nested) {
			rule.nested = true;
			rule.level = 1;
		} else {
			++rule.level;
		}
	});

	// make this media contain only rulesets
	ruleList = {
		type: 'ruleList',
		children: rulesets,
		loc: rulesets[0].loc,
	};
	media.children[1] = ruleList;

	// append flattened rules bellow this media
	rules.unshift(media);
	return rules;
};

Normalizer.prototype.visit_keyframes = function (keyframes) {
	var ruleList = this.visit(keyframes.children[1]);
	var children = ruleList.children;
	if (!ruleList.empty && !children.length) return null;
};

Normalizer.prototype.visit_keyframe =
Normalizer.prototype.visit_page = function (node) {
	var ruleList = this.visit(node.children[1]);
	if (!ruleList.empty && !ruleList.children.length) return null;
};

Normalizer.prototype.visit_fontFace = function (fontFace) {
	var ruleList = this.visit(fontFace.children[0]);
	if (!ruleList.empty && !ruleList.children.length) return null;
};

Normalizer.prototype.visit_range = function (range) {
	return Node.toListNode(range);
};

Normalizer.prototype.visit_list = function (list) {
	var children = this.visit(list.children);
	var items = [];

	for (var i = 0, len = children.length; i < len; ++i) {
		var child = children[i];
		if (child.type === 'list') items = items.concat(child.children);
		else items.push(child);
	}

	if (items.length === 1) return items[0];
	list.children = items;
};