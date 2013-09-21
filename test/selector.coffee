assert = require './assert'

suite 'selector'

test "flatten selector nested in selector", ->
	assert.compileTo '''
		body { div {} }
	''', '''
		body div {}
	'''

test "flatten compound selectors nested in selector list", ->
	assert.compileTo '''
		body {
			a:hover,
			span:hover {}
		}
	''', '''
		body a:hover,
		body span:hover {}
	'''

test "flatten selector nested in selector list", ->
	assert.compileTo '''
		html, body { div {} }
	''', '''
		html div,
		body div {}
	'''

test "flatten selector nested in selector list", ->
	assert.compileTo '''
		body { div, p {} }
	''', '''
		body div,
		body p {}
	'''

test "flatten selector list nested in selector list", ->
	assert.compileTo '''
		html, body { div, p {} }
	''', '''
		html div,
		html p,
		body div,
		body p {}
	'''

test "flatten deeply nested selector", ->
	assert.compileTo '''
		html { body { div {} } }
	''', '''
		html body div {}
	'''

test "flatten selector starting with combinator nested in selector", ->
	assert.compileTo '''
		body { > div {} }
	''', '''
		body > div {}
	'''

test "disallow top-level selector to start with a combinator", ->
	assert.failAt '''
		> div {}
	''', {line: 1, column: 1}

test "flatten selector list containing selector starting with combinator nested in selector list", ->
	assert.compileTo '''
		body, div { > p, img {} }
	''', '''
		body > p,
		body img,
		div > p,
		div img {}
	'''

test "flatten & selector nested in selector", ->
	assert.compileTo '''
		body { & {} }
	''', '''
		body {}
	'''

test "flatten selector containing & selector nested in selector list", ->
	assert.compileTo '''
		body, div { & p {} }
	''', '''
		body p,
		div p {}
	'''

test "flatten selector list containing & selector nested in selector", ->
	assert.compileTo '''
		body div { &, img {} }
	''', '''
		body div,
		body div img {}
	'''

test 'disallow top-level & selector', ->
	assert.failAt '''
		& {}
	''', {line: 1, column: 1}

test "flatten & selector followed by identifier nested in selector", ->
	assert.compileTo '''
		.menu { &-item {} }
	''', '''
		.menu-item {}
	'''

test "flatten & selector followed by identifier prepended with dash nested in selector", ->
	assert.compileTo '''
		.menu { &--item {} }
	''', '''
		.menu--item {}
	'''

test "disallow & selector followed by identifier to result nested in invalid selector", ->
	assert.failAt '''
		[type=button] { &-item {} }
	''', { line: 1, column: 17 }

test "flatten selector containing & selector nested in selector", ->
	assert.compileTo '''
		body { html & {} }
	''', '''
		html body {}
	'''