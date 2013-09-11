assert = require './assert'

suite 'media'

test "nest media containing property in ruleset", ->
	assert.compileTo '''
		body {
			@media screen {
				margin: auto;
			}
		}
	''', '''
		@media screen {
			body {
				margin: auto;
			}
		}
	'''

test "disallow top-level media to contain property", ->
	assert.failAt '''
		@media screen {
			margin: auto;
		}
	''', { line: 1, column: 1 }

test 'deeply nested medias', ->
	assert.compileTo '''
		@media screen {
			body {
				width: auto;

				@media (color) {
					@media (monochrome) {
						height: auto;
					}
				}
				div {
					height: auto;
				}
			}
			@media (monochrome) {
				p {
					margin: auto;
				}
			}
		}
	''', '''
		@media screen {
			body {
				width: auto;
			}
				body div {
					height: auto;
				}
		}
			@media screen and (color) and (monochrome) {
				body {
					height: auto;
				}
			}
			@media screen and (monochrome) {
				p {
					margin: auto;
				}
			}
	'''

test "nest empty media in ruleset", ->
	assert.compileTo '''
		body {
			@media screen {}
		}
	''', '''
		@media screen {
			body {}
		}
	'''
