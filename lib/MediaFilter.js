/**
 * MediaFilter
 *
 * Find medias matching the media query
 */
var Node = require('roole-node');
var Visitor = require('tree-visitor');
var stop = {};

module.exports = MediaFilter;

function MediaFilter() {}

MediaFilter.prototype = new Visitor();

MediaFilter.prototype.filter = function (nodes, mqList) {
	this.mediaQueryList = mqList;
	this.medias = [];

	try {
		this.visit(nodes);
	} catch (err) {
		if (err !== stop) throw err;
	}

	return this.medias;
};

MediaFilter.prototype.visit_void =
MediaFilter.prototype.visit_ruleset =
MediaFilter.prototype.visit_ruleList = function (node) {
	this.visit(node.children);
};

MediaFilter.prototype.visit_media = function (media) {
	var mqList = media.children[0];
	if (mqList === this.mediaQueryList) {
		this.medias.push(media);
		throw stop;
	}

	if (Node.equal(mqList, this.mediaQueryList)) this.medias.push(media);
	else this.visit(media.children[1]);
};