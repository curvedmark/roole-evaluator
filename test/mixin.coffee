assert = require './assert'

suite 'mixin'

test "mixin function", ->
	assert.compileTo '''
		$size = @function {
		  width: 100px;
		};

		a {
			@mixin $size();
		}
	''', '''
		a {
			width: 100px;
		}
	'''

test "mixin ruleset", ->
	assert.compileTo '''
		.btn {
			display: inline-block;
		}

		.submit {
			@mixin .btn;
		}
	''', '''
		.btn {
			display: inline-block;
		}

		.submit {
			display: inline-block;
		}
	'''

test "mixin later ruleset", ->
	assert.compileTo '''
		.submit {
			@mixin .btn;
		}

		.btn {
			display: inline-block;
		}
	''', '''
		.submit {
			display: inline-block;
		}

		.btn {
			display: inline-block;
		}
	'''

test "mixin rulesets with selector list", ->
	assert.compileTo '''
		.btn {
			display: inline-block;
		}

		.tab {
			float: left;
		}

		.submit {
			@mixin .btn, .tab;
		}
	''', '''
		.btn {
			display: inline-block;
		}

		.tab {
			float: left;
		}

		.submit {
			display: inline-block;
			float: left;
		}
	'''

test "mixin rulesets multiple times", ->
	assert.compileTo '''
		.btn {
			display: inline-block;
		}

		.tab {
			float: left;
		}

		.submit {
			@mixin .btn;
			@mixin .tab;
		}
	''', '''
		.btn {
			display: inline-block;
		}

		.tab {
			float: left;
		}

		.submit {
			display: inline-block;
			float: left;
		}
	'''

test "ignore ruleset nested in media", ->
	assert.compileTo '''
		@media screen {
			.btn {
				display: inline-block;
			}
		}

		.submit {
			@mixin .btn;
		}
	''', '''
		@media screen {
			.btn {
				display: inline-block;
			}
		}
	'''

test "in-media mixin", ->
	assert.compileTo '''
		.btn {
			display: inline-block;
		}

		@media screen {
			.submit {
				@mixin .btn;
			}
		}
	''', '''
		.btn {
			display: inline-block;
		}

		@media screen {
			.submit {
				display: inline-block;
			}
		}
	'''

test "function called within a mixin", ->
	assert.compileTo '''
		$bar = @function {
			@return 80px;
		};

		$foo = @function {
			width: $bar();
		};

		a {
			@mixin $foo();
		}
	''', '''
		a {
			width: 80px;
		}
	'''

test "mixin ruleset from another file", ->
	assert.compileTo {
		'/btn.roo': '''
			.btn {
				display: inline-block;
			}
		'''
		'/index.roo': '''
			@import './btn.roo';

			.submit {
				@mixin .btn;
			}
		'''
	}, '''
		.btn {
			display: inline-block;
		}

		.submit {
			display: inline-block;
		}
	'''

test "mixin ruleset from later file", ->
	assert.compileTo {
		'/btn.roo': '''
			.btn {
				display: inline-block;
			}
		'''
		'/index.roo': '''
			.submit {
				@mixin .btn;
			}

			@import './btn.roo';
		'''
	}, '''
		.submit {
			display: inline-block;
		}

		.btn {
			display: inline-block;
		}
	'''