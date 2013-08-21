var assert = require('assert');
var Promise = require('promise-now');
var parser = require('roole-parser');
var compiler = require('roole-compiler');
var evaluator = require('..');
require('mocha-as-promised')();

exports.compileTo = function (input, css) {
	var opts = {
		filename: '/index.roo',
		out: '/'
	};

	if (typeof input !== 'string') {
		opts.imports = input;
		input = input['/index.roo'];
	}

	return new Promise().fulfill().then(function () {
		var ast = parser.parse(input, opts);
		return evaluator.evaluate(ast, opts);
	}).then(function (ast) {
		var output = compiler.compile(ast);
		if (css) css += '\n';
		assert.equal(output, css);
	}, function (err) {
		if (err.loc) {
			err.message = "(" + err.loc.line + ":" + err.loc.column + " "
				+ err.loc.filename + ") "
				+ err.message;
		}
		throw err;
	});
};

exports.failAt = function (input, loc) {
	var opts = {
		filename: '/index.roo',
		out: '/'
	};

	if (typeof input !== 'string') {
		opts.imports = input;
		input = input['/index.roo'];
	}

	return new Promise().fulfill().then(function () {
		var ast = parser.parse(input, opts);
		return evaluator.evaluate(ast, opts);
	}).then(function () {
		throw new Error('No error was thrown');
	}, function (err) {
		if (!err.loc) throw err;

		assert.strictEqual(err.loc.line, loc.line, "Failed at line " + err.loc.line + " instead of " + loc.line);
		assert.strictEqual(err.loc.column, loc.column, "Failed at column " + err.loc.column + " instead of " + loc.column);
		if (loc.filename) assert.strictEqual(err.loc.filename, loc.filename, "Failed in file " + err.loc.filename + " instead of " + loc.filename);
	});
};