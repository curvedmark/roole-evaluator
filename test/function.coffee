assert = require './assert'

suite 'function'

test "calc() with variables", ->
	assert.compileTo '''
		$margin = 50%;
		$padding = 20px + 10px;
		a {
			content: calc($margin + $padding);
		}
	''', '''
		a {
			content: calc(50% + 30px);
		}
	'''

test "no params", ->
	assert.compileTo '''
		$width = @function {
			@return 960px;
		};

		a {
			width: $width();
		}
	''', '''
		a {
			width: 960px;
		}
	'''

test "not allow undefined function", ->
	assert.failAt '''
		a {
			width: $width();
		}
	''', {line: 2, column: 9}

test "not allow non-function to be called", ->
	assert.failAt '''
		$width = 960px;

		a {
			width: $width();
		}
	''', {line: 4, column: 9}

test "not allow using @return outside @function", ->
	assert.failAt '''
		a {
			@return 1;
		}
	''', {line: 2, column: 2}

test "call function multiple times", ->
	assert.compileTo '''
		a {
			$value = 960px;
			$get-value = @function {
				@return $value;
			};

			width: $get-value();

			$value = 400px;
			height: $get-value();
		}

	''', '''
		a {
			width: 960px;
			height: 400px;
		}
	'''

test "specify parameter", ->
	assert.compileTo '''
		$width = @function $width {
			@return $width;
		};

		a {
			width: $width(960px);
		}
	''', '''
		a {
			width: 960px;
		}
	'''

test "specify default parameter", ->
	assert.compileTo '''
		$width = @function $width = 960px {
			@return $width;
		};

		a {
			width: $width();
		}
	''', '''
		a {
			width: 960px;
		}
	'''

test "specify default parameter, overriden", ->
	assert.compileTo '''
		$width = @function $width = 960px {
			@return $width;
		};

		a {
			width: $width(400px);
		}
	''', '''
		a {
			width: 400px;
		}
	'''

test "under-specify arguments", ->
	assert.compileTo '''
		$margin = @function $h, $v {
			@return $h $v;
		};

		a {
			margin: $margin(20px);
		}
	''', '''
		a {
			margin: 20px null;
		}
	'''

test "rest argument", ->
	assert.compileTo '''
		$lasts = @function $num, ...$rest {
			@return $rest;
		};

		a {
			content: $lasts(1, 2, 3, 4);
		}
	''', '''
		a {
			content: 2, 3, 4;
		}
	'''

test "empty rest argument", ->
	assert.compileTo '''
		$lasts = @function $num, ...$rest {
			@return $rest;
		};

		a {
			content: $lasts();
		}
	''', '''
		a {
			content: [];
		}
	'''

test "ignore rules under @return", ->
	assert.compileTo '''
		$width = @function {
			$width = 960px;
			@return $width;

			$width = 400px;
			@return $width;
		};

		a {
			width: $width();
		}
	''', '''
		a {
			width: 960px;
		}
	'''

test "ignore block rules", ->
	assert.compileTo '''
		$width = @function {
			div {
				margin: 0;
			}

			$width = 960px;
			@return $width;
		};

		a {
			width: $width();
		}
	''', '''
		a {
			width: 960px;
		}
	'''

test "implicit @return", ->
	assert.compileTo '''
		$width = @function {
			div {
				margin: 0;
			}
		};

		a {
			width: $width();
		}
	''', '''
		a {
			width: null;
		}
	'''

test "$arguments", ->
	assert.compileTo '''
		$arguments = @function {
			@return $arguments;
		};

		a {
			content: $arguments(foo, bar)
		}
	''', '''
		a {
			content: foo, bar;
		}
	'''

test "empty $arguments", ->
	assert.compileTo '''
		$arguments = @function {
			@return $arguments;
		};

		a {
			content: $arguments()
		}
	''', '''
		a {
			content: [];
		}
	'''

test "do not modify arguments by direct assignment", ->
	assert.compileTo '''
		$modify = @function $param {
			$param = 1;
			@return $param;
		};

		a {
			$arg = 0;
			content: $modify($arg) $arg;
		}
	''', '''
		a {
			content: 1 0;
		}
	'''

test "lexical scope", ->
	assert.compileTo '''
		$var = 1;
		$func = @function {
			@return $var;
		};

		a {
			$var = 2;
			content: $func();
		}
	''', '''
		a {
			content: 1;
		}
	'''