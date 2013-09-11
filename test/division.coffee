assert = require './assert'

suite 'division'

test "number / number", ->
	assert.compileTo '''
		a {
			content: 1 / 2;
		}
	''', '''
		a {
			content: 0.5;
		}
	'''

test "number / 0, not allowed", ->
	assert.failAt '''
		a {
			content: 1 / 0;
		}
	''', {line: 2, column: 15}

test "number / number, needs truncation", ->
	assert.compileTo '''
		a {
			content: 1 / 3;
		}
	''', '''
		a {
			content: 0.33333;
		}
	'''

test "number / percentage", ->
	assert.compileTo '''
		a {
			content: 2 / 1%;
		}
	''', '''
		a {
			content: 2%;
		}
	'''

test "number / 0%, not allowed", ->
	assert.failAt '''
		a {
			content: 1 / 0%;
		}
	''', {line: 2, column: 15}

test "number / dimension", ->
	assert.compileTo '''
		a {
			content: 1 / 2px;
		}
	''', '''
		a {
			content: 0.5px;
		}
	'''

test "number / 0px, not allowed", ->
	assert.failAt '''
		a {
			content: 1 / 0px;
		}
	''', {line: 2, column: 15}

test "percentage / number", ->
	assert.compileTo '''
		a {
			content: 1% / 2;
		}
	''', '''
		a {
			content: 0.5%;
		}
	'''

test "percentage / 0, not allowed", ->
	assert.failAt '''
		a {
			content: 1% / 0;
		}
	''', {line: 2, column: 16}

test "percentage / percentage", ->
	assert.compileTo '''
		a {
			content: 1% / 1%;
		}
	''', '''
		a {
			content: 1;
		}
	'''

test "percentage / 0%, not allowed", ->
	assert.failAt '''
		a {
			content: 1% / 0%;
		}
	''', {line: 2, column: 16}

test "percentage / dimension, not allowed", ->
	assert.failAt '''
		a {
			content: 1% / 2px;
		}
	''', {line: 2, column: 11}

test "dimension / number", ->
	assert.compileTo '''
		a {
			content: 1px / 1;
		}
	''', '''
		a {
			content: 1px;
		}
	'''

test "dimension / 0, not allowed", ->
	assert.failAt '''
		a {
			content: 1px / 0;
		}
	''', {line: 2, column: 17}

test "dimension / percentage, not allowed", ->
	assert.failAt '''
		a {
			content: 1px / 2%;
		}
	''', {line: 2, column: 11}

test "dimension / dimension", ->
	assert.compileTo '''
		a {
			content: 1px / 1px;
		}
	''', '''
		a {
			content: 1;
		}
	'''

test "dimension / dimension, different units", ->
	assert.compileTo '''
		a {
			content: 1em / 2px;
		}
	''', '''
		a {
			content: 0.5;
		}
	'''

test "dimension / 0px, not allowed", ->
	assert.failAt '''
		a {
			content: 1px / 0px;
		}
	''', {line: 2, column: 17}

test "number/ number", ->
	assert.compileTo '''
		a {
			content: 1/ 2;
		}
	''', '''
		a {
			content: 0.5;
		}
	'''

test "number /number", ->
	assert.compileTo '''
		a {
			content: 1 /2;
		}
	''', '''
		a {
			content: 0.5;
		}
	'''
