assert = require './assert'

suite 'multiplication'

test "number * number", ->
	assert.compileTo '''
		a {
			content: 1 * 2;
		}
	''', '''
		a {
			content: 2;
		}
	'''

test "number * percentage", ->
	assert.compileTo '''
		a {
			content: 2 * 1%;
		}
	''', '''
		a {
			content: 2%;
		}
	'''

test "number * dimension", ->
	assert.compileTo '''
		a {
			content: 1 * 2px;
		}
	''', '''
		a {
			content: 2px;
		}
	'''

test "percentage * number", ->
	assert.compileTo '''
		a {
			content: 1% * 2;
		}
	''', '''
		a {
			content: 2%;
		}
	'''

test "percentage * percentage, not allowed", ->
	assert.failAt '''
		a {
			content: 1% * 1%;
		}
	''', { line: 2, column: 11 }

test "percentage * dimension, not allowed", ->
	assert.failAt '''
		a {
			content: 1% * 2px;
		}
	''', { line: 2, column: 11 }

test "dimension * number", ->
	assert.compileTo '''
		a {
			content: 1px * 1;
		}
	''', '''
		a {
			content: 1px;
		}
	'''

test "dimension * dimension, not allowed", ->
	assert.failAt '''
		a {
			content: 1px * 1px;
		}
	''', { line: 2, column: 11 }

test "number*number", ->
	assert.compileTo '''
		a {
			content: 1*2;
		}
	''', '''
		a {
			content: 2;
		}
	'''

test "number* number", ->
	assert.compileTo '''
		a {
			content: 1* 2;
		}
	''', '''
		a {
			content: 2;
		}
	'''

test "number *number", ->
	assert.compileTo '''
		a {
			content: 1 *2;
		}
	''', '''
		a {
			content: 2;
		}
	'''
