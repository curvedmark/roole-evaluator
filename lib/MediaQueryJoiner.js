/**
 * MediaQueryJoiner
 *
 * Flatten nested media queries
 */
var Node = require('roole-node');
var Transformer = require('tree-transformer');

module.exports = MediaQueryJoiner;

function MediaQueryJoiner() {}

MediaQueryJoiner.prototype = new Transformer();

MediaQueryJoiner.prototype.join = function (ancMqList, mqList) {
	this.ancestorMediaQueryList = ancMqList;
	return this.visit(mqList);
};

MediaQueryJoiner.prototype.visit_mediaQueryList = function (mqList) {
	if (!this.ancestorMediaQueryList) return mqList;

	var children = [];
	var ancMqs = this.ancestorMediaQueryList.children;

	var last = ancMqs.length - 1;

	ancMqs.forEach(function (ancMq, i) {
		this.ancestorMediaQuery = ancMq;

		var mqs = mqList.children;
		if (i !== last) mqs = Node.clone(mqs, false);

		children = children.concat(this.visit(mqs));
	}, this);
	mqList.children = children;

	return mqList;
};

MediaQueryJoiner.prototype.visit_mediaQuery = function (mq) {
	mq.children = this.ancestorMediaQuery.children.concat(mq.children);
};