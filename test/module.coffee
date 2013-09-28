assert = require './assert'

suite '@module'

test "default separator", ->
	assert.compileTo '''
		@module .foo {
			.button {}
		}
	''', '''
		.foo-button {}
	'''

test "specify separator", ->
	assert.compileTo '''
		@module .foo with '--' {
			.button {}
		}
	''', '''
		.foo--button {}
	'''

test "nest properties directly", ->
	assert.compileTo '''
		@module .foo {
			width: 100px;

			.button {}
		}
	''', '''
		.foo {
			width: 100px;
		}
			.foo-button {}
	'''

test "nest medias directly", ->
	assert.compileTo '''
		@module .foo {
			@media screen {
				width: 100px;
			}

			.button {}
		}
	''', '''
		@media screen {
			.foo {
				width: 100px;
			}
		}

		.foo-button {}
	'''

test "nest under ruleset", ->
	assert.compileTo '''
		body {
			@module .foo {
				width: 100px;

				.button {}
			}
		}
	''', '''
		body .foo {
			width: 100px;
		}
			body .foo-button {}
	'''


test "nested selectors", ->
	assert.compileTo '''
		@module .foo {
			.tabs .tab {}
		}
	''', '''
		.foo-tabs .foo-tab {}
	'''

test "chained selectors", ->
	assert.compileTo '''
		@module .foo {
			.button.active {}
		}
	''', '''
		.foo-button.foo-active {}
	'''

test "nested modules", ->
	assert.compileTo '''
		@module .foo {
			@module .bar {
				.button {}
			}
		}
	''', '''
		.foo-bar-button {}
	'''

test "disallow invalid module name", ->
	assert.failAt '''
		$sel = foo;
		@module $sel {
			.button {}
		}
	''', { line: 2, column: 9 }

test "disallow invalid module separator", ->
	assert.failAt '''
		$func = @function {};
		@module .foo with $func {
			.button {}
		}
	''', { line: 2, column: 19 }

test "selector interpolation as module name", ->
	assert.compileTo '''
		$sel = '.foo';
		@module $sel {
			width: 100px;
		}
	''', '''
		.foo {
			width: 100px;
		}
	'''

test "disallow interpolated complex selector as module name", ->
	assert.failAt '''
		$sel = '.foo .bar';
		@module $sel {
			width: 100px;
		}
	''', { line: 2, column: 9 }

test "extend module", ->
	assert.compileTo '''
		@module .foo {
			width: 100px;

			.button {}
		}

		.bar {
			@extend .foo;
		}
	''', '''
		.foo,
		.bar {
			width: 100px;
		}
			.foo-button {}
	'''

test "extend nested in module", ->
	assert.compileTo '''
		.bar {
			width: 100px
		}

		@module .foo {
			@extend .bar;
		}
	''', '''
		.bar,
		.foo {
			width: 100px;
		}
	'''

test "extend nested in module", ->
	assert.compileTo {
		'/bar.roo': '''
			@void {
				.bar {
					width: 100px
				}
			}

			baz {
				@extend .bar;
			}
		'''
		'/index.roo': '''
			@import './bar.roo';
			@module .foo {
				display: block;
				@extend .bar;
			}
		'''
	}, '''
		baz,
		.foo {
			width: 100px;
		}

		.foo {
			display: block;
		}
	'''

test "mixin nested in module", ->
	assert.compileTo '''
		.bar {
			width: 100px
		}

		@module .foo {
			@mixin .bar;
		}
	''', '''
		.bar {
			width: 100px;
		}

		.foo {
			width: 100px;
		}
	'''