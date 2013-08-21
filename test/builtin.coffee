assert = require './assert'

suite 'Builtin'

test "$len(list)", ->
	assert.compileTo '''
		a {
			content: $len(a b);
		}
	''', '''
		a {
			content: 2;
		}
	'''

test "$len(value)", ->
	assert.compileTo '''
		a {
			content: $len(a);
		}
	''', '''
		a {
			content: 1;
		}
	'''

test "$len()", ->
	assert.compileTo '''
		a {
			content: $len();
		}
	''', '''
		a {
			content: null;
		}
	'''

test "$unit(number)", ->
	assert.compileTo '''
		a {
			content: $unit(1);
		}
	''', '''
		a {
			content: "";
		}
	'''

test "$unit(percentage)", ->
	assert.compileTo '''
		a {
			content: $unit(1%);
		}
	''', '''
		a {
			content: "%";
		}
	'''

test "$unit(dimension)", ->
	assert.compileTo '''
		a {
			content: $unit(1px);
		}
	''', '''
		a {
			content: "px";
		}
	'''

test "$unit(identifier)", ->
	assert.compileTo '''
		a {
			content: $unit(px);
		}
	''', '''
		a {
			content: null;
		}
	'''

test "$unit()", ->
	assert.compileTo '''
		a {
			content: $unit();
		}
	''', '''
		a {
			content: null;
		}
	'''

test "$unit(number, percentage)", ->
	assert.compileTo '''
		a {
			content: $unit(1, 1%);
		}
	''', '''
		a {
			content: 1%;
		}
	'''

test "$unit(percentage, dimension)", ->
	assert.compileTo '''
		a {
			content: $unit(1%, 2px);
		}
	''', '''
		a {
			content: 1px;
		}
	'''

test "$unit(dimension, identifier)", ->
	assert.compileTo '''
		a {
			content: $unit(1%, em);
		}
	''', '''
		a {
			content: 1em;
		}
	'''


test "$unit(dimension, empty string)", ->
	assert.compileTo '''
		a {
			content: $unit(1%, "");
		}
	''', '''
		a {
			content: 1;
		}
	'''

test "$unit(number, percentage string)", ->
	assert.compileTo '''
		a {
			content: $unit(1, "%");
		}
	''', '''
		a {
			content: 1%;
		}
	'''

test "$unit(dimension, string)", ->
	assert.compileTo '''
		a {
			content: $unit(1%, 'px');
		}
	''', '''
		a {
			content: 1px;
		}
	'''

test "$unit(number, identifier)", ->
	assert.compileTo '''
		a {
			content: $unit(1, px);
		}
	''', '''
		a {
			content: 1px;
		}
	'''

test "$unit(number, null)", ->
	assert.compileTo '''
		a {
			content: $unit(1, null);
		}
	''', '''
		a {
			content: 1;
		}
	'''

test "$unit(dimension, null)", ->
	assert.compileTo '''
		a {
			content: $unit(1px, null);
		}
	''', '''
		a {
			content: 1;
		}
	'''

test "$opp(left)", ->
	assert.compileTo '''
		a {
			content: $opp(left);
		}
	''', '''
		a {
			content: right;
		}
	'''

test "$opp('top')", ->
	assert.compileTo '''
		a {
			content: $opp('top');
		}
	''', '''
		a {
			content: 'bottom';
		}
	'''

test "$opp(center)", ->
	assert.compileTo '''
		a {
			content: $opp(center);
		}
	''', '''
		a {
			content: center;
		}
	'''

test "$opp(top right)", ->
	assert.compileTo '''
		a {
			content: $opp(top right);
		}
	''', '''
		a {
			content: bottom left;
		}
	'''

test "$opp(top dimension)", ->
	assert.compileTo '''
		a {
			content: $opp(top 1px);
		}
	''', '''
		a {
			content: bottom 1px;
		}
	'''

test "$__dirname", ->
	assert.compileTo {
		'/tabs/index.roo': '''
			li {
				background: url("$__dirname/bg.png")
			}
		'''
		'/index.roo': '''
			@import './tabs';
		'''
	}, '''
		li {
			background: url("tabs/bg.png");
		}
	'''