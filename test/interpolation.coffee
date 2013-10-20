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
			content: "Figure \\{\\$chapter}-12";
		}
	''', '''
		figcaption {
			content: "Figure \\{\\$chapter}-12";
		}
	'''

test 'string interpolating braced identifier', ->
	assert.compileTo '''
		figcaption {
			content: "Figure {chapter}-12";
		}
	''', '''
		figcaption {
			content: "Figure chapter-12";
		}
	'''

test 'string interpolating addition', ->
	assert.compileTo '''
		figcaption {
			content: "Figure { 5 + 1 }-12";
		}
	''', '''
		figcaption {
			content: "Figure 6-12";
		}
	'''

test 'string interpolating string', ->
	assert.compileTo '''
		figcaption {
			content: "Figure { "#6" }-12";
		}
	''', '''
		figcaption {
			content: "Figure #6-12";
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
	''', { line: 6, column: 7 }

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
	''', '''
		.button {}
	'''

test 'disallow selector interpolating invalid selector', ->
	assert.failAt '''
		$sel = '#';
		$sel {}
	''', { line: 2, column: 1 }

test 'disallow selector interpolating top-level & selector', ->
	assert.failAt '''
		$sel = '&';
		$sel {}
	''', { line: 2, column: 1 }

test 'complex selector interpolating selector', ->
	assert.compileTo '''
		$sel = ' .icon ';
		.button $sel {}
	''', '''
		.button .icon {}
	'''

test 'complex selector interpolating selector staring with combinator', ->
	assert.compileTo '''
		$sel = ' >  .icon';
		.button $sel {}
	''', '''
		.button > .icon {}
	'''

test 'disallow complex selector interpolating top-level & selector', ->
	assert.failAt '''
		$sel = '& div';
		body $sel {}
	''', { line: 2, column: 6 }

test 'complex selector interpolating & selector nested in selector', ->
	assert.compileTo '''
		$sel = ' & .icon ';
		.ie {
			.button $sel {}
		}
	''', '''
		.button .ie .icon {}
	'''

test 'selector interpolating identifier', ->
	assert.compileTo '''
		$sel = button;
		$sel {}
	''', '''
		button {}
	'''

test 'disallow complex selector interpolating selector list', ->
	assert.failAt '''
		$sel = 'div, p';
		body $sel {}
	''', { line: 2, column: 6 }

test 'selector interpolating selector list', ->
	assert.compileTo '''
		$sel = ' button , .btn';
		$sel {}
	''', '''
		button,
		.btn {}
	'''

test 'selector list interpolating selector list', ->
	assert.compileTo '''
		$sel = ' .btn,button';
		.button, $sel {}
	''', '''
		.button,
		.btn,
		button {}
	'''

test 'media type interpolating string', ->
	assert.compileTo '''
		$mq = 'not  screen';
		@media $mq {}
	''', '''
		@media not screen {}
	'''

test 'media query interpolating string', ->
	assert.compileTo '''
		$mq = '( max-width: 980px )';
		@media screen and $mq {}
	''', '''
		@media screen and (max-width: 980px) {}
	'''

test 'media query list interpolating string', ->
	assert.compileTo '''
		$mq1 = ' only screen  and (color) ';
		$mq2 = '(monochrome)';
		@media $mq1, $mq2 {}
	''', '''
		@media only screen and (color), (monochrome) {}
	'''

test 'media query interpolating identifier', ->
	assert.compileTo '''
		$mq = screen;
		@media $mq {}
	''', '''
		@media screen {}
	'''

test 'disallow media query interpolating invalid media query', ->
	assert.failAt '''
		$mq = 'screen #';
		@media $mq {}
	''', { line: 2, column: 8 }

test 'disallow complex media query interpolating media query list', ->
	assert.failAt '''
		$mq = '(color), (monochrome)';
		@media screen and $mq {}
	''', { line: 2, column: 19 }

test 'media query interpolating media query list', ->
	assert.compileTo '''
		$mq = '(color), (monochrome)';
		@media $mq {}
	''', '''
		@media (color), (monochrome) {}
	'''

test 'media query list interpolating media query list', ->
	assert.compileTo '''
		$mq = '(color), (monochrome)';
		@media screen, $mq {}
	''', '''
		@media screen, (color), (monochrome) {}
	'''