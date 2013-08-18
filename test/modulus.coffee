assert = require './assert'

suite 'modulus'

test "number % number", ->
	assert.compileTo '''
		a {
			content: 3 % 2;
		}
	''', '''
		a {
			content: 1;
		}
	'''

test "number % 0, not allowed", ->
	assert.failAt '''
		a {
			content: 3 % 0;
		}
	''', { line: 2, column: 15 }

test "number % percentage", ->
	assert.compileTo '''
		a {
			content: 3 % 2%;
		}
	''', '''
		a {
			content: 1%;
		}
	'''

test "number % 0%, not allowed", ->
	assert.failAt '''
		a {
			content: 3 % 0%;
		}
	''', { line: 2, column: 15 }

test "number % dimension", ->
	assert.compileTo '''
		a {
			content: 3 % 2px;
		}
	''', '''
		a {
			content: 1px;
		}
	'''

test "number % 0px, not allowed", ->
	assert.failAt '''
		a {
			content: 3 % 0px;
		}
	''', { line: 2, column: 15 }

test "percentage % number", ->
	assert.compileTo '''
		a {
			content: 4% % 2;
		}
	''', '''
		a {
			content: 0%;
		}
	'''

test "percentage % 0, not allowed", ->
	assert.failAt '''
		a {
			content: 4% % 0;
		}
	''', { line: 2, column: 16 }


test "percentage % dimension, not allowed", ->
	assert.failAt '''
		a {
			content: 4% % 2px;
		}
	''', { line: 2, column: 11 }

test "dimension % number", ->
	assert.compileTo '''
		a {
			content: 3px % 2;
		}
	''', '''
		a {
			content: 1px;
		}
	'''

test "dimension % 0, not allowed", ->
	assert.failAt '''
		a {
			content: 3px % 0;
		}
	''', { line: 2, column: 17 }

test "dimension % percentage, not allowed", ->
	assert.failAt '''
		a {
			content: 3px % 2%;
		}
	''', { line: 2, column: 11 }

test "dimension % dimension", ->
	assert.compileTo '''
		a {
			content: 3px % 2px;
		}
	''', '''
		a {
			content: 1;
		}
	'''

test "dimension % dimension, different units", ->
	assert.compileTo '''
		a {
			content: 3px % 2em;
		}
	''', '''
		a {
			content: 1;
		}
	'''