assert = require './assert'

suite 'unary'

test "+number", ->
	assert.compileTo '''
		body {
			-foo: +1;
		}
	''', '''
		body {
			-foo: 1;
		}
	'''

test "+percentage", ->
	assert.compileTo '''
		body {
			-foo: +1%;
		}
	''', '''
		body {
			-foo: 1%;
		}
	'''

test "+dimension", ->
	assert.compileTo '''
		body {
			-foo: +1px;
		}
	''', '''
		body {
			-foo: 1px;
		}
	'''

test "+string, not allowed", ->
	assert.failAt '''
		body {
			-foo: +'a';
		}
	''', {line: 2, column: 8}

test "-number", ->
	assert.compileTo '''
		body {
			-foo: -1;
		}
	''', '''
		body {
			-foo: -1;
		}
	'''

test "-percentage", ->
	assert.compileTo '''
		body {
			-foo: -1%;
		}
	''', '''
		body {
			-foo: -1%;
		}
	'''

test "-dimension", ->
	assert.compileTo '''
		body {
			-foo: -1px;
		}
	''', '''
		body {
			-foo: -1px;
		}
	'''

test "-variable, value is number", ->
	assert.compileTo '''
		$foo = 1px;
		body {
			-foo: -$foo;
		}
	''', '''
		body {
			-foo: -1px;
		}
	'''

test "-variable, value is identifier", ->
	assert.compileTo '''
		$foo = foo;
		body {
			-foo: -$foo;
		}
	''', '''
		body {
			-foo: -foo;
		}
	'''
