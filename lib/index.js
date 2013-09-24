var Evaluator = require('./Evaluator');

exports.evaluate = function (node, options) {
	return new Evaluator(options).evaluate(node);
};

exports.Evaluator = Evaluator;