assert = require './assert'

test "flatten nested ruleset", ->
	assert.compileTo '''
		body {
			margin: auto;
			div {}
		}
	''', '''
		body {
			margin: auto;
		}
			body div {}
	'''

test "flatten deeply nested ruleset", ->
	assert.compileTo '''
		body {
			margin: auto;
			div {
				width: auto;
				p {
					height: auto;
				}
			}
		}
	''', '''
		body {
			margin: auto;
		}
			body div {
				width: auto;
			}
				body div p {
					height: auto;
				}
	'''