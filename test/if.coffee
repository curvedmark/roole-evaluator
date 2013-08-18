assert = require './assert'

suite '@if'

test "true condition", ->
	assert.compileTo '''
		@if true {
			body {}
		}
	''', '''
		body {}
	'''

test "list as true condition", ->
	assert.compileTo '''
		@if '', '' {
			body {}
		}
	''', '''
		body {}
	'''

test "false condition", ->
	assert.compileTo '''
		@if false {
			body {}
		}
	''', ''

test "0 as false condition", ->
	assert.compileTo '''
		@if 0 {
			body {}
		}
	''', ''

test "0% as false condition", ->
	assert.compileTo '''
		@if 0% {
			body {}
		}
	''', ''

test "0px as false condition", ->
	assert.compileTo '''
		@if 0px {
			body {}
		}
	''', ''

test "empty string as false condition", ->
	assert.compileTo '''
		@if '' {
			body {}
		}
	''', ''

test "@else if", ->
	assert.compileTo '''
		body {
			@if false {
				width: auto;
			} @else if true {
				height: auto;
			}
		}
	''', '''
		body {
			height: auto;
		}
	'''

test "short-ciruit @else if", ->
	assert.compileTo '''
		body {
			@if false {
				width: auto;
			} @else if false {
				height: auto;
			} @else if true {
				margin: auto;
			} @else if true {
				padding: auto;
			}
		}
	''', '''
		body {
			margin: auto;
		}
	'''

test "@else", ->
	assert.compileTo '''
		body {
			@if false {
				width: auto;
			} @else {
				height: auto;
			}
		}
	''', '''
		body {
			height: auto;
		}
	'''

test "@else with @else if", ->
	assert.compileTo '''
		body {
			@if false {
				width: auto;
			} @else if false {
				height: auto;
			} @else {
				margin: auto;
			}
		}
	''', '''
		body {
			margin: auto;
		}
	'''
