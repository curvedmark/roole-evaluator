assert = require './assert'

suite '@module'

test "default separator", ->
	assert.compileTo '''
		@module foo {
			.button {}
		}
	''', '''
		.foo-button {}
	'''

test "specify separator", ->
	assert.compileTo '''
		@module foo with '--' {
			.button {}
		}
	''', '''
		.foo--button {}
	'''

test "nested selectors", ->
	assert.compileTo '''
		@module foo {
			.tabs .tab {}
		}
	''', '''
		.foo-tabs .foo-tab {}
	'''

test "chained selectors", ->
	assert.compileTo '''
		@module foo {
			.button.active {}
		}
	''', '''
		.foo-button.foo-active {}
	'''

test "nested modules", ->
	assert.compileTo '''
		@module foo {
			@module bar {
				.button {}
			}
		}
	''', '''
		.foo-bar-button {}
	'''

test "not allow invalid module name", ->
	assert.failAt '''
		$func = @function {};
		@module $func {
			.button {}
		}
	''', {line: 2, column: 9}

test "not allow invalid module separator", ->
	assert.failAt '''
		$func = @function {};
		@module foo with $func {
			.button {}
		}
	''', {line: 2, column: 18}
