assert = require './assert'

suite 'addition'

test "number + number", ->
	assert.compileTo '''
		a {
			content: 1 + 1;
		}
	''', '''
		a {
			content: 2;
		}
	'''

test "number + percentage", ->
	assert.compileTo '''
		a {
			content: 1 + 1%;
		}
	''', '''
		a {
			content: 2%;
		}
	'''

test "number + dimension", ->
	assert.compileTo '''
		a {
			content: 1 + 1px;
		}
	''', '''
		a {
			content: 2px;
		}
	'''

test "number + identifier", ->
	assert.compileTo '''
		a {
			content: 1 + px;
		}
	''', '''
		a {
			content: 1px;
		}
	'''

test "number + string", ->
	assert.compileTo '''
		a {
			content: 1 + 'str';
		}
	''', '''
		a {
			content: '1str';
		}
	'''

test "percentage + number", ->
	assert.compileTo '''
		a {
			content: 1% + 1;
		}
	''', '''
		a {
			content: 2%;
		}
	'''

test "percentage + percentage", ->
	assert.compileTo '''
		a {
			content: 1% + 1%;
		}
	''', '''
		a {
			content: 2%;
		}
	'''

test "percentage + dimension, not allowed", ->
	assert.failAt '''
		a {
			content: 2% + 1px;
		}
	''', { line: 2, column: 11 }

test "percentage + string", ->
	assert.compileTo '''
		a {
			content: 2% + 'str';
		}
	''', '''
		a {
			content: '2%str';
		}
	'''

test "dimension + number", ->
	assert.compileTo '''
		a {
			content: 1px + 1;
		}
	''', '''
		a {
			content: 2px;
		}
	'''

test "dimension + dimension", ->
	assert.compileTo '''
		a {
			content: 1px + 1px;
		}
	''', '''
		a {
			content: 2px;
		}
	'''

test "dimension + dimension, different units", ->
	assert.compileTo '''
		a {
			content: 1em + 1px;
		}
	''', '''
		a {
			content: 2em;
		}
	'''

test "dimension + identifier, not allowed", ->
	assert.failAt '''
		a {
			content: 1px + id;
		}
	''', { line: 2, column: 11 }

test "dimension + string", ->
	assert.compileTo '''
		a {
			content: 1px + 'str';
		}
	''', '''
		a {
			content: '1pxstr';
		}
	'''

test "boolean + identifier", ->
	assert.compileTo '''
		a {
			content: true + id;
		}
	''', '''
		a {
			content: trueid;
		}
	'''

test "boolean + string", ->
	assert.compileTo '''
		a {
			content: true + 'str';
		}
	''', '''
		a {
			content: 'truestr';
		}
	'''

test "identifier + number", ->
	assert.compileTo '''
		a {
			content: id + 1;
		}
	''', '''
		a {
			content: id1;
		}
	'''

test "identifier + identifier", ->
	assert.compileTo '''
		a {
			content: -webkit + -moz;
		}
	''', '''
		a {
			content: -webkit-moz;
		}
	'''

test "identifier + dimension", ->
	assert.compileTo '''
		a {
			content: id + 1px;
		}
	''', '''
		a {
			content: id1px;
		}
	'''

test "identifier + boolean", ->
	assert.compileTo '''
		a {
			content: id + true;
		}
	''', '''
		a {
			content: idtrue;
		}
	'''

test "identifier + str", ->
	assert.compileTo '''
		a {
			content: id + 'str';
		}
	''', '''
		a {
			content: 'idstr';
		}
	'''

test "string + number", ->
	assert.compileTo '''
		a {
			content: 'str' + 1;
		}
	''', '''
		a {
			content: 'str1';
		}
	'''

test "string + percentage", ->
	assert.compileTo '''
		a {
			content: 'str' + 1%;
		}
	''', '''
		a {
			content: 'str1%';
		}
	'''

test "string + dimension", ->
	assert.compileTo '''
		a {
			content: 'str' + 1px;
		}
	''', '''
		a {
			content: 'str1px';
		}
	'''

test "string + boolean", ->
	assert.compileTo '''
		a {
			content: 'str' + false;
		}
	''', '''
		a {
			content: 'strfalse';
		}
	'''

test "string + identifier", ->
	assert.compileTo '''
		a {
			content: 'str' + id;
		}
	''', '''
		a {
			content: 'strid';
		}
	'''

test "string + string", ->
	assert.compileTo '''
		a {
			content: 'foo' + 'bar';
		}
	''', '''
		a {
			content: 'foobar';
		}
	'''

test "string + string, different quotes", ->
	assert.compileTo '''
		a {
			content: "foo" + 'bar';
		}
	''', '''
		a {
			content: "foobar";
		}
	'''

test "number+number", ->
	assert.compileTo '''
		a {
			content: 1+1;
		}
	''', '''
		a {
			content: 2;
		}
	'''

test "number+ number", ->
	assert.compileTo '''
		a {
			content: 1+ 1;
		}
	''', '''
		a {
			content: 2;
		}
	'''
