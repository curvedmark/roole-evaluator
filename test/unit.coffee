assert = require './assert'

suite 'unit'

test "()%", ->
	assert.compileTo '''
		a {
			content: 1px%;
		}
	''', '''
		a {
			content: 1%;
		}
	'''

test "()em", ->
	assert.compileTo '''
		a {
			content: (1 + 1)em;
		}
	''', '''
		a {
			content: 2em;
		}
	'''

test "not allow invalid number", ->
	assert.failAt '''
		a {
			content: (abc)em;
		}
	''', { line: 2, column: 12 }