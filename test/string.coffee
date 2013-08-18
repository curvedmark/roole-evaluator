assert = require './assert'

test "single-quoted string with escaped quote", ->
	assert.compileTo '''
		a {
			content: '"a\\'';
		}
	''', '''
		a {
			content: '"a\\'';
		}
	'''

test "empty single-quoted string", ->
	assert.compileTo '''
		a {
			content: '';
		}
	''', '''
		a {
			content: '';
		}
	'''

test "double-quoted string with escaped quote", ->
	assert.compileTo '''
		a {
			content: "'a0\\"";
		}
	''', '''
		a {
			content: "'a0\\"";
		}
	'''

test "empty double-quoted string", ->
	assert.compileTo '''
		a {
			content: "";
		}
	''', '''
		a {
			content: "";
		}
	'''