/**
 * Scope
 *
 * Regulate lexical scoping
 */
module.exports = Scope;

function Scope(frame) {
	this.frames = [frame || {}];
}

Scope.prototype.clone = function () {
	var scope = new Scope();
	scope.frames = this.frames.slice(0);
	return scope;
};

Scope.prototype.push = function(frame) {
	this.frames.push(frame || {});
};

Scope.prototype.pop = function() {
	this.frames.pop();
};

Scope.prototype.define = function(name, value) {
	this.frames[this.frames.length - 1][name] = value;
};

Scope.prototype.overwrite = function(name, value) {
	var frame = this.findFrame(name);
	if (!frame) this.define(name, value);
	else frame[name] = value;
};

Scope.prototype.resolve = function(name) {
	var frame = this.findFrame(name);
	if (frame) return frame[name];
};

Scope.prototype.findFrame = function (name) {
	var length = this.frames.length;
	while (length--) {
		if (name in this.frames[length]) return this.frames[length];
	}
};