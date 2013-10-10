assert = require './assert'

suite "media query"

test "flatten media feature nested in media type", ->
	assert.compileTo '''
		@media screen { @media (color) {} }
	''', '''
		@media screen and (color) {}
	'''

test 'flatten media type nested in media type', ->
	assert.compileTo '''
		@media screen { @media not print {} }
	''', '''
		@media screen and not print {}
	'''

test 'flatten media query list nested in media query', ->
	assert.compileTo '''
		@media screen { @media (color), (monochrome) {} }
	''', '''
		@media screen and (color), screen and (monochrome) {}
	'''

test 'flatten media query nested in media query list', ->
	assert.compileTo '''
		@media screen, print { @media (color) {} }
	''', '''
		@media screen and (color), print and (color) {}
	'''

test 'flatten media query list nested in media query list', ->
	assert.compileTo '''
		@media screen, print { @media (color), (monochrome) {} }
	''', '''
		@media screen and (color), screen and (monochrome), print and (color), print and (monochrome) {}
	'''

test 'flatten deeply nested media query', ->
	assert.compileTo '''
		@media screen { @media (color) { @media (monochrome) {} } }
	''', '''
		@media screen and (color) and (monochrome) {}
	'''