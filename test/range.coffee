assert = require './assert'

suite 'range'

test "natural range", ->
	assert.compileTo '''
		a {
			content: 1..3;
		}
	''', '''
		a {
			content: 1 2 3;
		}
	'''

test "natural exclusive range", ->
	assert.compileTo '''
		a {
			content: 1...3;
		}
	''', '''
		a {
			content: 1 2;
		}
	'''

test "reversed range", ->
	assert.compileTo '''
		a {
			content: 3..1;
		}
	''', '''
		a {
			content: 3 2 1;
		}
	'''

test "reversed exclusive range", ->
	assert.compileTo '''
		a {
			content: 3...1;
		}
	''', '''
		a {
			content: 3 2;
		}
	'''

test "one number range", ->
	assert.compileTo '''
		a {
			content: 1..1;
		}
	''', '''
		a {
			content: 1;
		}
	'''

test "empty range", ->
	assert.compileTo '''
		a {
			content: 1...1;
		}
	''', '''
		a {
			content: [];
		}
	'''

test "percentage range", ->
	assert.compileTo '''
		a {
			content: 0%..2%;
		}
	''', '''
		a {
			content: 0% 1% 2%;
		}
	'''

test "dimension range", ->
	assert.compileTo '''
		a {
			content: 100px..102px;
		}
	''', '''
		a {
			content: 100px 101px 102px;
		}
	'''

test "mixed range", ->
	assert.compileTo '''
		a {
			content: 1px..3%;
		}
	''', '''
		a {
			content: 1px 2px 3px;
		}
	'''

test "reversed single-number mixed exclusiverange", ->
	assert.compileTo '''
		a {
			content: 2px...1%;
		}
	''', '''
		a {
			content: 2px;
		}
	'''

test "start number must be numberic", ->
	assert.failAt '''
		a {
			content: a...3;
		}
	''', {line: 2, column: 11}

test "end number must be numberic", ->
	assert.failAt '''
		a {
			content: 1..b;
		}
	''', {line: 2, column: 14}

test "arithmetic range", ->
	assert.compileTo '''
		a {
			content: 1 + 1..5 - 2;
		}
	''', '''
		a {
			content: 2 3;
		}
	'''