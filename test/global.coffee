assert = require './assert'

suite 'global opiton'

test "null", ->
	assert.compileTo {
		global: { val: null }
	}, '''
		a {
			content: $val;
		}
	''', '''
		a {
			content: null;
		}
	'''

test "identifier", ->
	assert.compileTo {
		global: { val: 'foo' }
	}, '''
		a {
			content: $val;
		}
	''', '''
		a {
			content: foo;
		}
	'''

test "dimension", ->
	assert.compileTo {
		global: { val: '12px' }
	}, '''
		a {
			content: $val;
		}
	''', '''
		a {
			content: 12px;
		}
	'''

test "string", ->
	assert.compileTo {
		global: { val: "'str'" }
	}, '''
		a {
			content: $val;
		}
	''', '''
		a {
			content: 'str';
		}
	'''

test "function", ->
	assert.compileTo {
		global: { val: -> '12px' }
	}, '''
		a {
			content: $val();
		}
	''', '''
		a {
			content: 12px;
		}
	'''