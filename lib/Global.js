var path = require('path')

module.exports = Global;

function Global(opts) {
	// $__dirname
	var dirname = opts.filename;
	if (dirname.slice(-1) !== path.sep) dirname = path.dirname(dirname);
	this.__dirname = {
		type: 'string',
		quote: '"',
		children: [dirname === path.sep ? '' : dirname]
	};

	// $__relname
	var out = opts.out;
	var relname = path.relative(out, dirname) || '.';
	this.__relname = {
		type: 'string',
		quote: '"',
		children: [relname]
	};
}