assert = require './assert'

suite 'Builtin'

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

test "$__dirname, url as path", ->
	assert.compileTo {
		'http://example.com/tabs/index.roo': '''
			li {
				background: url("$__dirname/bg.png")
			}
		'''
		'http://example.com/index.roo': '''
			@import './tabs';
		'''
	}, '''
		li {
			background: url("tabs/bg.png");
		}
	'''

test "$__dirname, url as path with compiled css at a different domain", ->
	assert.compileTo {
		out: 'http://google.com/'
	}, {
		'http://example.com/tabs/index.roo': '''
			li {
				background: url("$__dirname/bg.png")
			}
		'''
		'http://example.com/index.roo': '''
			@import './tabs';
		'''
	}, '''
		li {
			background: url("http://example.com/tabs/bg.png");
		}
	'''

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

test "$len(empty list)", ->
	assert.compileTo '''
		a {
			content: $len([]);
		}
	''', '''
		a {
			content: 0;
		}
	'''

test "$len(one item list)", ->
	assert.compileTo '''
		a {
			content: $len([1]);
		}
	''', '''
		a {
			content: 1;
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

test "$len(range)", ->
	assert.compileTo '''
		a {
			content: $len(-1..1);
		}
	''', '''
		a {
			content: 3;
		}
	'''

test "$len(reversed range)", ->
	assert.compileTo '''
		a {
			content: $len(2..1);
		}
	''', '''
		a {
			content: 2;
		}
	'''

test "$len(exclusive range)", ->
	assert.compileTo '''
		a {
			content: $len(1...3);
		}
	''', '''
		a {
			content: 2;
		}
	'''

test "$len(reversed exclusive range)", ->
	assert.compileTo '''
		a {
			content: $len(-3...-1);
		}
	''', '''
		a {
			content: 2;
		}
	'''

test "$len(empty range)", ->
	assert.compileTo '''
		a {
			content: $len(0...0);
		}
	''', '''
		a {
			content: 0;
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

test "$list()", ->
	assert.compileTo '''
		a {
			content: $list();
		}
	''', '''
		a {
			content: [];
		}
	'''

test "$list(list)", ->
	assert.compileTo '''
		a {
			content: $list(1 2);
		}
	''', '''
		a {
			content: 1 2;
		}
	'''

test "$list(range)", ->
	assert.compileTo '''
		a {
			content: $list(1..3);
		}
	''', '''
		a {
			content: 1 2 3;
		}
	'''

test "$list(value)", ->
	assert.compileTo '''
		a {
			content: $list(1)[0];
		}
	''', '''
		a {
			content: 1;
		}
	'''

test "$list(list, sep)", ->
	assert.compileTo '''
		a {
			content: $list(1 2, ',');
		}
	''', '''
		a {
			content: 1, 2;
		}
	'''

test "$list(range, sep)", ->
	assert.compileTo '''
		a {
			content: $list(1..3, '/');
		}
	''', '''
		a {
			content: 1/2/3;
		}
	'''

test "$list(val, sep)", ->
	assert.compileTo '''
		a {
			content: $list(1, ' ');
		}
	''', '''
		a {
			content: 1;
		}
	'''

test "$list(list, invalid sep)", ->
	assert.compileTo '''
		a {
			content: $list([1, 2], '%');
		}
	''', '''
		a {
			content: 1, 2;
		}
	'''