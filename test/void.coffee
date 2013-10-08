assert = require './assert'

suite '@void'

test "ruleset", ->
	assert.compileTo '''
		@void { body {} }
	''', ''

test "mixin ruleset", ->
	assert.compileTo '''
		@void { .button { margin: 0 } }

		#submit {
			@mixin .button;
		}
	''', '''
		#submit {
			margin: 0;
		}
	'''