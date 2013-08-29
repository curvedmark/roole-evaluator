assert = require './assert'

suite 'Global'

test "$__dirname", ->
	assert.compileTo {
		'/tabs/index.roo': '''
			.tabs {
				background: url("$__dirname/bg.png")
			}
		'''
		'/index.roo': '''
			@import './tabs';

			body {
				background: url("$__dirname/bg.png")
			}
		'''
	}, '''
		.tabs {
			background: url("/tabs/bg.png");
		}

		body {
			background: url("/bg.png");
		}
	'''

test "$__relname", ->
	assert.compileTo {
		'/tabs/index.roo': '''
			.tabs {
				background: url("$__relname/bg.png")
			}
		'''
		'/index.roo': '''
			@import './tabs';

			body {
				background: url("$__relname/bg.png")
			}
		'''
	}, '''
		.tabs {
			background: url("tabs/bg.png");
		}

		body {
			background: url("./bg.png");
		}
	'''