/**
 * fs loader
 *
 * Get file content at `path` using fs
 */
var fs = require('fs');

exports.load = function(path, cb) {
	fs.readFile(path, 'utf8', cb);
};