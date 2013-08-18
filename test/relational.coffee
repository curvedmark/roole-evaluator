assert = require './assert'

suite 'relational'

test "number < number", ->
	assert.compileTo '''
		a {
			content: 1 < 2;
		}
	''', '''
		a {
			content: true;
		}
	'''

test "number <= number", ->
	assert.compileTo '''
		a {
			content: 2 <= 2;
		}
	''', '''
		a {
			content: true;
		}
	'''

test "number > number", ->
	assert.compileTo '''
		a {
			content: 2 > 2;
		}
	''', '''
		a {
			content: false;
		}
	'''

test "number >= number", ->
	assert.compileTo '''
		a {
			content: 2 >= 3;
		}
	''', '''
		a {
			content: false;
		}
	'''

test "number >= identifer", ->
	assert.compileTo '''
		a {
			content: 2 >= abc;
		}
	''', '''
		a {
			content: false;
		}
	'''

test "identifer < number", ->
	assert.compileTo '''
		a {
			content: abc < 2;
		}
	''', '''
		a {
			content: false;
		}
	'''

test "identifier < identifier", ->
	assert.compileTo '''
		a {
			content: a < b;
		}
	''', '''
		a {
			content: true;
		}
	'''

test "string > string", ->
	assert.compileTo '''
		a {
			content: 'b' > 'a';
		}
	''', '''
		a {
			content: true;
		}
	'''
