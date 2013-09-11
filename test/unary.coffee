assert = require './assert'

suite 'unary'

test "+number", ->
	assert.compileTo '''
		a {
			content: +1;
		}
	''', '''
		a {
			content: 1;
		}
	'''

test "+percentage", ->
	assert.compileTo '''
		a {
			content: +1%;
		}
	''', '''
		a {
			content: 1%;
		}
	'''

test "+dimension", ->
	assert.compileTo '''
		a {
			content: +1px;
		}
	''', '''
		a {
			content: 1px;
		}
	'''

test "+string, not allowed", ->
	assert.failAt '''
		a {
			content: +'a';
		}
	''', { line: 2, column: 11 }

test "-number", ->
	assert.compileTo '''
		a {
			content: -1;
		}
	''', '''
		a {
			content: -1;
		}
	'''

test "-percentage", ->
	assert.compileTo '''
		a {
			content: -1%;
		}
	''', '''
		a {
			content: -1%;
		}
	'''

test "-dimension", ->
	assert.compileTo '''
		a {
			content: -1px;
		}
	''', '''
		a {
			content: -1px;
		}
	'''

test "-variable, value is number", ->
	assert.compileTo '''
		$foo = 1px;
		a {
			content: -$foo;
		}
	''', '''
		a {
			content: -1px;
		}
	'''

test "-variable, value is identifier", ->
	assert.compileTo '''
		$foo = foo;
		a {
			content: -$foo;
		}
	''', '''
		a {
			content: -foo;
		}
	'''
