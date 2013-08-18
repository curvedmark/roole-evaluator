assert = require './assert'

suite 'logical'

test "true and false", ->
	assert.compileTo '''
		a {
			content: true and false;
		}
	''', '''
		a {
			content: false;
		}
	'''

test "true and true", ->
	assert.compileTo '''
		a {
			content: true and true;
		}
	''', '''
		a {
			content: true;
		}
	'''

test "false and true", ->
	assert.compileTo '''
		a {
			content: false and true;
		}
	''', '''
		a {
			content: false;
		}
	'''

test "false and false", ->
	assert.compileTo '''
		a {
			content: false and false;
		}
	''', '''
		a {
			content: false;
		}
	'''

test "true or false", ->
	assert.compileTo '''
		a {
			content: true or false;
		}
	''', '''
		a {
			content: true;
		}
	'''

test "true or true", ->
	assert.compileTo '''
		a {
			content: true or true;
		}
	''', '''
		a {
			content: true;
		}
	'''

test "false or true", ->
	assert.compileTo '''
		a {
			content: false or true;
		}
	''', '''
		a {
			content: true;
		}
	'''

test "false or false", ->
	assert.compileTo '''
		a {
			content: false or false;
		}
	''', '''
		a {
			content: false;
		}
	'''

test "true and false or true", ->
	assert.compileTo '''
		a {
			content: true and false or true;
		}
	''', '''
		a {
			content: true;
		}
	'''
