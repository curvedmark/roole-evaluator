assert = require './assert'

suite 'Builtin'

test "ignore mixin builtins", ->
	assert.compileTo '''
		body {
			margin: 0;
			@mixin $len();
		}
	''', '''
		body {
			margin: 0;
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

test "$len(string)", ->
	assert.compileTo '''
		a {
			content: $len('abc');
		}
	''', '''
		a {
			content: 3;
		}
	'''

test "$len(empty string)", ->
	assert.compileTo '''
		a {
			content: $len('abc');
		}
	''', '''
		a {
			content: 3;
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
			content: px;
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

test "$push()", ->
	assert.compileTo '''
		a {
			content: $push();
		}
	''', '''
		a {
			content: null;
		}
	'''

test "$push(list)", ->
	assert.compileTo '''
		a {
			content: $push(0 1);
		}
	''', '''
		a {
			content: 0 1;
		}
	'''

test "disallow $push(non-list, value)", ->
	assert.failAt '''
		$push(1, 1);
	''', { line: 1, column: 7 }

test "$push(list, value) changes list", ->
	assert.compileTo '''
		$list = 0, 1;
		$push($list, a);
		a {
			content: $list;
		}
	''', '''
		a {
			content: 0, 1, a;
		}
	'''

test "$push(list, value, list)", ->
	assert.compileTo '''
		a {
			content: $push([0, 1], a, [2 3]);
		}
	''', '''
		a {
			content: 0, 1, a, 2 3;
		}
	'''

test "$push(empty list, value)", ->
	assert.compileTo '''
		a {
			content: $push([], a);
		}
	''', '''
		a {
			content: a;
		}
	'''

test "$push(empty list, value, list)", ->
	assert.compileTo '''
		a {
			content: $push([], a, 1 2);
		}
	''', '''
		a {
			content: a 1 2;
		}
	'''

test "$unshift()", ->
	assert.compileTo '''
		a {
			content: $unshift();
		}
	''', '''
		a {
			content: null;
		}
	'''

test "$unshift(list)", ->
	assert.compileTo '''
		a {
			content: $unshift(0 1);
		}
	''', '''
		a {
			content: 0 1;
		}
	'''

test "disallow $unshift(non-list, value)", ->
	assert.failAt '''
		$unshift(1, 1);
	''', { line: 1, column: 10 }

test "$unshift(list, value) changes list", ->
	assert.compileTo '''
		$list = 0, 1;
		$unshift($list, a);
		a {
			content: $list;
		}
	''', '''
		a {
			content: a, 0, 1;
		}
	'''

test "$unshift(list, value, list)", ->
	assert.compileTo '''
		a {
			content: $unshift([0, 1], a, [2 3]);
		}
	''', '''
		a {
			content: a 2 3 0, 1;
		}
	'''

test "$unshift(empty list, value)", ->
	assert.compileTo '''
		a {
			content: $unshift([], a);
		}
	''', '''
		a {
			content: a;
		}
	'''

test "$unshift(empty list, list, value)", ->
	assert.compileTo '''
		a {
			content: $unshift([], 1 2, a);
		}
	''', '''
		a {
			content: 1 2 a;
		}
	'''

test "$pop()", ->
	assert.compileTo '''
		a {
			content: $pop();
		}
	''', '''
		a {
			content: null;
		}
	'''

test "$pop(list)", ->
	assert.compileTo '''
		a {
			content: $pop(0 1);
		}
	''', '''
		a {
			content: 1;
		}
	'''

test "disallow $pop(non-list)", ->
	assert.failAt '''
		$pop(1);
	''', { line: 1, column: 6 }

test "$pop(list) changes list", ->
	assert.compileTo '''
		$list = 0, 1;
		$pop($list);
		a {
			content: $list;
		}
	''', '''
		a {
			content: 0;
		}
	'''

test "$pop(empty list)", ->
	assert.compileTo '''
		a {
			content: $pop([]);
		}
	''', '''
		a {
			content: null;
		}
	'''

test "$pop(single-item list)", ->
	assert.compileTo '''
		$list = [0];
		$item = $pop($list);
		a {
			content: $item;
			content: $list;
		}
	''', '''
		a {
			content: 0;
			content: [];
		}
	'''

test "$shift()", ->
	assert.compileTo '''
		a {
			content: $shift();
		}
	''', '''
		a {
			content: null;
		}
	'''

test "$shift(list)", ->
	assert.compileTo '''
		a {
			content: $shift(0 1);
		}
	''', '''
		a {
			content: 0;
		}
	'''

test "disallow $shift(non-list)", ->
	assert.failAt '''
		$shift(1);
	''', { line: 1, column: 8 }

test "$shift(list) changes list", ->
	assert.compileTo '''
		$list = 0, 1;
		$shift($list);
		a {
			content: $list;
		}
	''', '''
		a {
			content: 1;
		}
	'''

test "$shift(empty list)", ->
	assert.compileTo '''
		a {
			content: $shift([]);
		}
	''', '''
		a {
			content: null;
		}
	'''

test "$shift(single-item list)", ->
	assert.compileTo '''
		$list = [0];
		$item = $shift($list);
		a {
			content: $item;
			content: $list;
		}
	''', '''
		a {
			content: 0;
			content: [];
		}
	'''

test "$img-size()", ->
	assert.compileTo '''
		a {
			content: $img-size();
		}
	''', '''
		a {
			content: null;
		}
	'''

test "$img-size(path)", ->
	assert.compileTo {
		filename: __filename
	}, '''
		a {
			content: $img-size('./img.gif');
		}
	''', '''
		a {
			content: 10px 5px;
		}
	'''

test "$img-size(prefixed path)", ->
	assert.compileTo {
		base: __dirname
	}, '''
		a {
			content: $img-size('img.gif');
		}
	''', '''
		a {
			content: 10px 5px;
		}
	'''

test "$img-size(absolute path)", ->
	assert.compileTo """
		a {
			content: $img-size('#{__dirname}/img.gif');
		}
	""", '''
		a {
			content: 10px 5px;
		}
	'''

test "$img-size(invalid path)", ->
	assert.failAt '''
		a {
			content: $img-size('/');
		}
	''', { line: 2, column: 11 }