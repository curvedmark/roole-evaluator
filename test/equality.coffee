assert = require './assert'

suite 'equality'

test "is, true", ->
	assert.compileTo '''
		a {
			content: 1 is 1;
		}
	''', '''
		a {
			content: true;
		}
	'''

test "is, false", ->
	assert.compileTo '''
		a {
			content: 1 is 2;
		}
	''', '''
		a {
			content: false;
		}
	'''

test "isnt, true", ->
	assert.compileTo '''
		a {
			content: 1 isnt 2;
		}
	''', '''
		a {
			content: true;
		}
	'''

test "isnt, false", ->
	assert.compileTo '''
		a {
			content: 1 isnt 1;
		}
	''', '''
		a {
			content: false;
		}
	'''

test "inclusive range isnt exclusive range", ->
	assert.compileTo '''
		a {
			content: 1..2 isnt 1...2;
		}
	''', '''
		a {
			content: true;
		}
	'''
