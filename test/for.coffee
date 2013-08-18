assert = require './assert'

suite '@for'

test "loop natural range", ->
	assert.compileTo '''
		@for $i in 1..3 {
			.span-$i {}
		}
	''', '''
		.span-1 {}

		.span-2 {}

		.span-3 {}
	'''

test "loop natural exclusive range", ->
	assert.compileTo '''
		@for $i in 1...3 {
			.span-$i {}
		}
	''', '''
		.span-1 {}

		.span-2 {}
	'''

test "loop one number range", ->
	assert.compileTo '''
		@for $i in 1..1 {
			.span-$i {}
		}
	''', '''
		.span-1 {}
	'''

test "loop empty range", ->
	assert.compileTo '''
		@for $i in 1...1 {
			.span-$i {}
		}
	''', ''

test "loop reversed range", ->
	assert.compileTo '''
		@for $i in 3..1 {
			.span-$i {}
		}
	''', '''
		.span-3 {}

		.span-2 {}

		.span-1 {}
	'''

test "loop reversed exclusive range", ->
	assert.compileTo '''
		@for $i in 3...1 {
			.span-$i {}
		}
	''', '''
		.span-3 {}

		.span-2 {}
	'''

test "loop with positive step", ->
	assert.compileTo '''
		@for $i by 2 in 1..4 {
			.span-$i {}
		}
	''', '''
		.span-1 {}

		.span-3 {}
	'''

test "loop with positive step for reversed range", ->
	assert.compileTo '''
		@for $i by 2 in 3..1 {
			.span-$i {}
		}
	''', '''
		.span-3 {}

		.span-1 {}
	'''

test "loop with negative step", ->
	assert.compileTo '''
		@for $i by -1 in 1...3 {
			.span-$i {}
		}
	''', '''
		.span-2 {}

		.span-1 {}
	'''

test "loop with negative step for reversed range", ->
	assert.compileTo '''
		@for $i by -2 in 3..1 {
			.span-$i {}
		}
	''', '''
		.span-1 {}

		.span-3 {}
	'''

test "not allow step number to be zero", ->
	assert.failAt '''
		@for $i by 0 in 1..3 {
			body {}
		}
	''', {line: 1, column: 12}

test "only allow step number to be numberic", ->
	assert.failAt '''
		@for $i by a in 1..3 {
			body {}
		}
	''', {line: 1, column: 12}

test "loop list", ->
	assert.compileTo '''
		$icons = foo bar, qux;
		@for $icon in $icons {
			.icon-$icon {}
		}
	''', '''
		.icon-foo {}

		.icon-bar {}

		.icon-qux {}
	'''

test "loop empty list", ->
	assert.compileTo '''
		@for $val, $key in 1...1 {}

		body {}
	''', '''
		body {}
	'''

test "loop number", ->
	assert.compileTo '''
		@for $i in 1 {
			.span-$i {}
		}
	''', '''
		.span-1 {}
	'''

test "loop list with index", ->
	assert.compileTo '''
		@for $icon, $i in foo bar, qux {
			.icon-$icon$i {}
		}
	''', '''
		.icon-foo0 {}

		.icon-bar1 {}

		.icon-qux2 {}
	'''

test "loop list with index with negative step", ->
	assert.compileTo '''
		@for $icon, $i by -1 in foo bar, qux {
			.icon-$icon$i {}
		}
	''', '''
		.icon-qux2 {}

		.icon-bar1 {}

		.icon-foo0 {}
	'''

test "loop value with index", ->
	assert.compileTo '''
		@for $icon, $i in foo {
			.icon-$icon$i {}
		}
	''', '''
		.icon-foo0 {}
	'''