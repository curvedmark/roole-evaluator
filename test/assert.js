var assert = require('assert');
var Promise = require('promise-now');
var parser = require('roole-parser');
var compiler = require('roole-compiler');
var evaluator = require('..');
require('mocha-as-promised')();

exports.compileTo = function (opts, input, css) {
	if (!css) {
		css = input;
		input = opts;
		opts = {}
	}

	if (!opts.filename) opts.filename = '/index.roo';
	if (!opts.base) opts.base = '/';

	if (typeof input !== 'string') {
		opts.imports = input;
		input = input['/index.roo'];
	}

	return new Promise().fulfill().then(function () {
		var ast = parser.parse(input, opts);
		return evaluator.evaluate(ast, opts);
	}).then(function (ast) {
		var output = compiler.compile(ast);
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
		base: '/'
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

		assert.strictEqual(err.loc.line, loc.line, "Failed at line " + err.loc.line + " instead of " + loc.line + ": " + err.toString());
		assert.strictEqual(err.loc.column, loc.column, "Failed at column " + err.loc.column + " instead of " + loc.column + ": " + err.toString());
		if (loc.filename) assert.strictEqual(err.loc.filename, loc.filename, "Failed in file " + err.loc.filename + " instead of " + loc.filename);
	});
};