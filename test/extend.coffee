assert = require './assert'

suite '@extend'

test "extend selector", ->
	assert.compileTo '''
		.button {}

		#submit {
			@extend .button;
		}
	''', '''
		.button,
		#submit {}
	'''

test "ignore subsequent selectors", ->
	assert.compileTo '''
		.button {}

		#submit {
			@extend .button;
		}

		.button {}
	''', '''
		.button,
		#submit {}

		.button {}
	'''

test "extend selector containing nested selector", ->
	assert.compileTo '''
		.button { .icon {} }

		#submit {
			@extend .button;
		}
	''', '''
		.button .icon,
		#submit .icon {}
	'''

test "extend selector containing deeply nested selector", ->
	assert.compileTo '''
		.button { .icon { img {} } }

		#submit {
			@extend .button;
		}
	''', '''
		.button .icon img,
		#submit .icon img {}
	'''

test "extend compound selector", ->
	assert.compileTo '''
		.button { & .icon {} }

		#submit .icon {
			@extend .button .icon;
		}
	''', '''
		.button .icon,
		#submit .icon {}
	'''

test "extend selector containing nested & selector", ->
	assert.compileTo '''
		.button { & .icon {} }

		#submit {
			@extend .button;
		}
	''', '''
		.button .icon,
		#submit .icon {}
	'''

test "extend selector with selector list", ->
	assert.compileTo '''
		.button .icon {}

		#submit .icon, #reset .icon {
			@extend .button .icon;
		}
	''', '''
		.button .icon,
		#submit .icon,
		#reset .icon {}
	'''

test "deeply extend selector", ->
	assert.compileTo '''
		.button {}

		.large-button {
			@extend .button;
		}

		#submit {
			@extend .large-button;
		}
	''', '''
		.button,
		.large-button,
		#submit {}
	'''

test "extend selector under the same ruleset", ->
	assert.compileTo '''
		.button {
			.icon {}

			.large-icon {
				@extend .button .icon;
			}
		}
	''', '''
		.button .icon,
		.button .large-icon {}
	'''

test "extend by multiple selectors", ->
	assert.compileTo '''
		.button {}

		#submit {
			@extend .button;
		}

		#reset {
			@extend .button;
		}
	''', '''
		.button,
		#submit,
		#reset {}
	'''

test "extend selector containing nested selector by multiple selectors", ->
	assert.compileTo '''
		.button { .icon {} }

		#submit {
			@extend .button;
		}

		#reset {
			@extend .button;
		}
	''', '''
		.button .icon,
		#submit .icon,
		#reset .icon {}
	'''

test "extend selector list", ->
	assert.compileTo '''
		.button-large {}
		.button-dangerous {}

		#reset {
			@extend .button-large, .button-dangerous;
		}
	''', '''
		.button-large,
		#reset {}

		.button-dangerous,
		#reset {}
	'''

test "extend selector with multiple @extend", ->
	assert.compileTo '''
		.button-large {}
		.button-dangerous {}

		#reset {
			@extend .button-large;
			@extend .button-dangerous;
		}
	''', '''
		.button-large,
		#reset {}

		.button-dangerous,
		#reset {}
	'''

test "extend selector containg nested @media", ->
	assert.compileTo '''
		.button {
			display: inline-block;
			@media screen {
				display: block;
			}
			@media print {
				display: none;
			}
		}

		#submit {
			@extend .button;
		}
	''', '''
		.button,
		#submit {
			display: inline-block;
		}
			@media screen {
				.button,
				#submit {
					display: block;
				}
			}
			@media print {
				.button,
				#submit {
					display: none;
				}
			}
	'''

test "extend selector nested in the same @media", ->
	assert.compileTo '''
		.button {
			display: inline-block;
		}

		@media print {
			.button {
				display: block;
			}
		}

		@media not screen {
			.button {
				display: block;
			}

			#submit {
				@extend .button;
			}
		}
	''', '''
		.button {
			display: inline-block;
		}

		@media print {
			.button {
				display: block;
			}
		}

		@media not screen {
			.button,
			#submit {
				display: block;
			}
		}
	'''

test "extend selector nested in @media with same media query", ->
	assert.compileTo '''
		@media screen {
			.button {
				display: inline-block;
			}

			@media (color), (monochrome) {
				.button {
					display: block;
				}
			}

			@media (color) {
				.button {
					display: inline-block;
				}
			}
		}

		@media screen and (color) {
			#submit {
				@extend .button;
			}
		}
	''', '''
		@media screen {
			.button {
				display: inline-block;
			}
		}
			@media
			screen and (color),
			screen and (monochrome) {
				.button {
					display: block;
				}
			}
			@media screen and (color) {
				.button,
				#submit {
					display: inline-block;
				}
			}
	'''

test "ignore subsequent @media", ->
	assert.compileTo '''
		@media screen and (color) {
			.button {
				display: inline-block;
			}
		}

		@media screen and (color) {
			#submit {
				@extend .button;
			}
		}

		@media screen and (color) {
			.button {
				display: block;
			}
		}
	''', '''
		@media screen and (color) {
			.button,
			#submit {
				display: inline-block;
			}
		}

		@media screen and (color) {
			.button {
				display: block;
			}
		}
	'''