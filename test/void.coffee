assert = require './assert'

suite '@void'

test "unextended ruleset", ->
	assert.compileTo '''
		@void { body {} }
	''', ''

test "extended ruleset", ->
	assert.compileTo '''
		@void { .button {} }

		#submit {
			@extend .button;
		}
	''', '''
		#submit {}
	'''
test "extend ruleset using @extend nested in @void", ->
	assert.compileTo '''
		@void {
			.button {
				display: inline-block;
				.icon {
					float: left;
				}
			}

			.large-button {
				@extend .button;
				display: block;
			}
		}

		#submit {
			@extend .large-button;
		}
	''', '''
		#submit {
			display: inline-block;
		}
			#submit .icon {
				float: left;
			}

		#submit {
			display: block;
		}
	'''

test "ignore ruleset outside @void when using @extend nested in @void", ->
	assert.compileTo '''
		.button {
			display: inline-block;
		}

		@void {
			.button {
				display: block;
			}

			.large-button {
				@extend .button;
			}
		}

		#submit {
			@extend .large-button;
		}
	''', '''
		.button {
			display: inline-block;
		}

		#submit {
			display: block;
		}
	'''