assert = require './assert'

suite 'subtraction'

test "number - number", ->
	assert.compileTo '''
		a {
			content: 1 - 1;
		}
	''', '''
		a {
			content: 0;
		}
	'''

test "number - percentage", ->
	assert.compileTo '''
		a {
			content: 1 - 1%;
		}
	''', '''
		a {
			content: 0%;
		}
	'''

test "number - dimension", ->
	assert.compileTo '''
		a {
			content: 1 - 2px;
		}
	''', '''
		a {
			content: -1px;
		}
	'''

test "percentage - number", ->
	assert.compileTo '''
		a {
			content: 1% - 2;
		}
	''', '''
		a {
			content: -1%;
		}
	'''

test "percentage - percentage", ->
	assert.compileTo '''
		a {
			content: 1% - 1%;
		}
	''', '''
		a {
			content: 0%;
		}
	'''

test "percentage - dimension, not allowed", ->
	assert.failAt '''
		a {
			content: 1% - 2px;
		}
	''', { line: 2, column: 11 }

test "dimension - number", ->
	assert.compileTo '''
		a {
			content: 1px - 1;
		}
	''', '''
		a {
			content: 0px;
		}
	'''

test "dimension - percentage, not allowed", ->
	assert.failAt '''
		a {
			content: 1px - 1%;
		}
	''', { line: 2, column: 11 }

test "dimension - dimension", ->
	assert.compileTo '''
		a {
			content: 1px - 1px;
		}
	''', '''
		a {
			content: 0px;
		}
	'''

test "dimension - dimension, different units", ->
	assert.compileTo '''
		a {
			content: 1em - 2px;
		}
	''', '''
		a {
			content: -1em;
		}
	'''

test "number-number", ->
	assert.compileTo '''
		a {
			content: 1-1;
		}
	''', '''
		a {
			content: 0;
		}
	'''

test "number- number", ->
	assert.compileTo '''
		a {
			content: 1- 1;
		}
	''', '''
		a {
			content: 0;
		}
	'''