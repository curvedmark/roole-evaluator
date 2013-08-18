assert = require './assert'

suite 'interpolation'

test "not interpolating single-quoted string", ->
	assert.compileTo '''
		a {
			content: '$var';
		}
	''', '''
		a {
			content: '$var';
		}
	'''

test "string interpolating identifier", ->
	assert.compileTo '''
		$name = guest;
		a {
			content: "hello $name";
		}
	''', '''
		a {
			content: "hello guest";
		}
	'''

test "string interpolating single-quoted string", ->
	assert.compileTo '''
		$name = 'guest';
		a {
			content: "hello $name";
		}
	''', '''
		a {
			content: "hello guest";
		}
	'''

test "string interpolating double-quoted string", ->
	assert.compileTo '''
		$name = "guest";
		a {
			content: "hello $name";
		}
	''', '''
		a {
			content: "hello guest";
		}
	'''

test "string interpolating single-quoted string containing double quotes", ->
	assert.compileTo '''
		$str = '"';
		a {
			content: "$str";
		}
	''', '''
		a {
			content: "\\"";
		}
	'''

test 'string interpolating braced variable', ->
	assert.compileTo '''
		$chapter = 4;
		figcaption {
			content: "Figure {$chapter}-12";
		}
	''', '''
		figcaption {
			content: "Figure 4-12";
		}
	'''

test 'string interpolating escaped braced variable', ->
	assert.compileTo '''
		figcaption {
			content: "Figure {\\$chapter}-12";
		}
	''', '''
		figcaption {
			content: "Figure {\\$chapter}-12";
		}
	'''

test 'string interpolating braced identifier', ->
	assert.compileTo '''
		$chapter = 4;
		figcaption {
			content: "Figure {chapter}-12";
		}
	''', '''
		figcaption {
			content: "Figure {chapter}-12";
		}
	'''

test 'identifier interpolating identifier', ->
	assert.compileTo '''
		$name = star;
		.icon-$name {
			float: left;
		}
	''', '''
		.icon-star {
			float: left;
		}
	'''

test 'identifier interpolating number', ->
	assert.compileTo '''
		$num = 12;
		.icon-$num {
			float: left;
		}
	''', '''
		.icon-12 {
			float: left;
		}
	'''

test 'identifier interpolating string', ->
	assert.compileTo '''
		$name = 'star';
		.icon-$name {
			float: left;
		}
	''', '''
		.icon-star {
			float: left;
		}
	'''

test 'not allow interpolating function', ->
	assert.failAt '''
		$name = @function {
			body {
				margin: auto;
			}
		};
		.icon-$name {
			float: left;
		}
	''', {line: 6, column: 7}

test 'identifier interpolating multiple variables', ->
	assert.compileTo '''
		$size = big;
		$name = star;
		.icon-$size$name {
			float: left;
		}
	''', '''
		.icon-bigstar {
			float: left;
		}
	'''

test 'identifier interpolating only two variables', ->
	assert.compileTo '''
		$prop = border;
		$pos = -left;
		body {
			$prop$pos: solid;
		}
	''', '''
		body {
			border-left: solid;
		}
	'''

test 'identifier interpolating braced variable', ->
	assert.compileTo '''
		$prop = border;
		body {
			{$prop}: solid;
		}
	''', '''
		body {
			border: solid;
		}
	'''

test 'identifier interpolating braced variable preceding a dash', ->
	assert.compileTo '''
		$prop = border;
		$pos = left;
		body {
			{$prop}-$pos: solid;
		}
	''', '''
		body {
			border-left: solid;
		}
	'''

test 'identifier interpolating two braced variables separated by double dashes', ->
	assert.compileTo '''
		$module = icon;
		$name = star;
		.{$module}--{$name} {
			display: inline-block;
		}
	''', '''
		.icon--star {
			display: inline-block;
		}
	'''

test 'identifier interpolating braced variable preceded by a dash', ->
	assert.compileTo '''
		$prefix = moz;
		$prop = box-sizing;
		body {
			-{$prefix}-$prop: border-box;
		}
	''', '''
		body {
			-moz-box-sizing: border-box;
		}
	'''

test 'selector interpolating string', ->
	assert.compileTo '''
		$sel = ' .button ';
		$sel {}

		#submit {
			@extend .button;
		}
	''', '''
		.button,
		#submit {}
	'''

test 'disallow selector interpolating invalid selector', ->
	assert.failAt '''
		$sel = '#';
		$sel {}
	''', {line: 2, column: 1}

test 'disallow selector interpolating top-level & selector', ->
	assert.failAt '''
		$sel = '&';
		$sel {}
	''', {line: 2, column: 1}

test 'complex selector interpolating selector', ->
	assert.compileTo '''
		$sel = '.icon ';
		.button $sel {}

		#submit .icon {
			@extend .button .icon
		}
	''', '''
		.button .icon,
		#submit .icon {}
	'''

test 'complex selector interpolating selector staring with combinator', ->
	assert.compileTo '''
		$sel = ' >  .icon';
		.button $sel {}

		#submit .icon {
			@extend .button > .icon
		}
	''', '''
		.button > .icon,
		#submit .icon {}
	'''

test 'disallow complex selector interpolating top-level & selector', ->
	assert.failAt '''
		$sel = '& div';
		body $sel {
			width: auto;
		}
	''', {line: 2, column: 6}

test 'complex selector interpolating & selector nested in selector', ->
	assert.compileTo '''
		$sel = '& .icon';
		.ie {
			.button $sel {}
		}

		#submit .icon {
			@extend .button .ie .icon;
		}
	''', '''
		.button .ie .icon,
		#submit .icon {}
	'''

test 'disallow selector interpolating selector list', ->
	assert.failAt '''
		$sel = 'div, p';
		$sel {}
	''', {line: 2, column: 1}

test 'selector interpolating identifier', ->
	assert.compileTo '''
		$sel = button;
		$sel {}

		#submit {
			@extend button;
		}
	''', '''
		button,
		#submit {}
	'''

test 'media type interpolating string', ->
	assert.compileTo '''
		$qry = 'not  screen';
		@media $qry {
			.button {}
		}

		@media not screen {
			#submit {
				@extend .button;
			}
		}
	''', '''
		@media not screen {
			.button,
			#submit {}
		}
	'''

test 'media query interpolating string', ->
	assert.compileTo '''
		$qry = '( max-width: 980px )';
		@media screen and $qry {
			.button {}
		}

		@media screen and (max-width: 980px) {
			#submit {
				@extend .button;
			}
		}
	''', '''
		@media screen and (max-width: 980px) {
			.button,
			#submit {}
		}
	'''

test 'media query list interpolating string', ->
	assert.compileTo '''
		$qry1 = ' only screen  and (color) ';
		$qry2 = '(monochrome)';
		@media $qry1, $qry2 {
			.button {}
		}

		@media only screen and (color), (monochrome) {
			#submit {
				@extend .button;
			}
		}
	''', '''
		@media
		only screen and (color),
		(monochrome) {
			.button,
			#submit {}
		}
	'''

test 'media query interpolating identifier', ->
	assert.compileTo '''
		$qry = screen;
		@media $qry {
			.button {}
		}

		@media screen {
			#submit {
				@extend .button;
			}
		}
	''', '''
		@media screen {
			.button,
			#submit {}
		}
	'''

test 'disallow media query interpolating invalid media query', ->
	assert.failAt '''
		$qry = 'screen #';
		@media $qry {
			body {}
		}
	''', {line: 2, column: 8}