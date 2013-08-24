assert = require './assert'

suite 'member'

test "access with number", ->
	assert.compileTo '''
		a {
			content: (0 1 2)[2];
		}
	''', '''
		a {
			content: 2;
		}
	'''

test "access with negative number", ->
	assert.compileTo '''
		a {
			content: (0 1 2)[-3];
		}
	''', '''
		a {
			content: 0;
		}
	'''

test "access with number, out of range", ->
	assert.compileTo '''
		a {
			content: [0 1 2][3];
		}
	''', '''
		a {
			content: null;
		}
	'''

test "access with negative number, out of range", ->
	assert.compileTo '''
		a {
			content: (0 1 2)[-4];
		}
	''', '''
		a {
			content: null;
		}
	'''

test "access value with number", ->
	assert.compileTo '''
		a {
			content: 1[0];
		}
	''', '''
		a {
			content: null;
		}
	'''

test "access value with negative number", ->
	assert.compileTo '''
		a {
			content: 1[-1];
		}
	''', '''
		a {
			content: null;
		}
	'''

test "access with range", ->
	assert.compileTo '''
		a {
			content: (0 1 2)[1..2];
		}
	''', '''
		a {
			content: 1 2;
		}
	'''

test "access with reversed range", ->
	assert.compileTo '''
		a {
			content: (0 1 2)[2..1];
		}
	''', '''
		a {
			content: 2 1;
		}
	'''

test "access with oversized range", ->
	assert.compileTo '''
		a {
			content: (0 1 2)[1..3];
		}
	''', '''
		a {
			content: 1 2;
		}
	'''

test "access with oversized reversed range", ->
	assert.compileTo '''
		a {
			content: (0 1 2)[3..1];
		}
	''', '''
		a {
			content: 2 1;
		}
	'''

test "access with one number range", ->
	assert.compileTo '''
		a {
			content: (0 1 2)[1..1][0];
		}
	''', '''
		a {
			content: 1;
		}
	'''

test "access with empty range", ->
	assert.compileTo '''
		a {
			content: (0 1 2)[1...1];
		}
	''', '''
		a {
			content: [];
		}
	'''

test "access with single-item range from positive to negative", ->
	assert.compileTo '''
		a {
			content: (0 1 2)[1..-2];
		}
	''', '''
		a {
			content: 1;
		}
	'''

test "access with single-item exclusive range", ->
	assert.compileTo '''
		a {
			content: (0 1 2)[1...2];
		}
	''', '''
		a {
			content: 1;
		}
	'''

test "access with single-item reversed exclusive range", ->
	assert.compileTo '''
		a {
			content: (0 1 2)[1...-3];
		}
	''', '''
		a {
			content: 1;
		}
	'''

test "access with out-of-range range", ->
	assert.compileTo '''
		a {
			content: (0 1 2)[3..4];
		}
	''', '''
		a {
			content: [];
		}
	'''

test "access with out-of-range reversed range", ->
	assert.compileTo '''
		a {
			content: (0 1 2)[4..3];
		}
	''', '''
		a {
			content: [];
		}
	'''

test "access with range, from negative to negative", ->
	assert.compileTo '''
		a {
			content: (0 1 2)[-2..-1];
		}
	''', '''
		a {
			content: 1 2;
		}
	'''

test "access with range, from negative to positive", ->
	assert.compileTo '''
		a {
			content: (0 1 2)[-2..2];
		}
	''', '''
		a {
			content: 1 2;
		}
	'''

test "access with range, from positive to negative", ->
	assert.compileTo '''
		a {
			content: (0 1 2)[1..-1];
		}
	''', '''
		a {
			content: 1 2;
		}
	'''

test "access with reversed range, from negative to negative", ->
	assert.compileTo '''
		a {
			content: (0 1 2)[-1..-2];
		}
	''', '''
		a {
			content: 2 1;
		}
	'''

test "access with reversed range, from negative to positive", ->
	assert.compileTo '''
		a {
			content: (0 1 2)[-1..1];
		}
	''', '''
		a {
			content: 2 1;
		}
	'''

test "access with reversed range, from positive to negative", ->
	assert.compileTo '''
		a {
			content: (0 1 2)[2..-2];
		}
	''', '''
		a {
			content: 2 1;
		}
	'''

test "access with invalid type", ->
	assert.compileTo '''
		a {
			content: (0 1 2)[true];
		}
	''', '''
		a {
			content: null;
		}
	'''

test "disallow access null", ->
	assert.failAt '''
		a {
			content: null[0];
		}
	''', { line: 2, column: 11 }

test "access range with number", ->
	assert.compileTo '''
		a {
			content: (1..3)[1];
		}
	''', '''
		a {
			content: 2;
		}
	'''

test "access should change loc", ->
	assert.failAt '''
		$list = [0%];
		$var = $list[0] + px;
	''', { line: 2, column: 8 }

test "access range with range", ->
	assert.compileTo '''
		a {
			content: (1..4)[1..2];
		}
	''', '''
		a {
			content: 2 3;
		}
	'''

test "access empty list with number", ->
	assert.compileTo '''
		a {
			content: [][0];
		}
	''', '''
		a {
			content: null;
		}
	'''

test "disallow assigning to non-list with member expression", ->
	assert.failAt '''
		$list = null;
		$list[0] = a;
	''', { line: 2, column: 1 }

test "disallow assigning to list with invalid member type", ->
	assert.failAt '''
		$list = 0 1 2;
		$list[null] = a;
	''', { line: 2, column: 7 }

test "assign with number", ->
	assert.compileTo '''
		$list = 0 1 2;
		$list[2] = a;
		a {
			content: $list;
		}
	''', '''
		a {
			content: 0 1 a;
		}
	'''

test "assign with negative number", ->
	assert.compileTo '''
		$list = 0 1 2;
		$list[-3] = a;
		a {
			content: $list;
		}
	''', '''
		a {
			content: a 1 2;
		}
	'''

test "assign to edge item with number", ->
	assert.compileTo '''
		$list = 0 1 2;
		$list[3] = a;
		a {
			content: $list;
		}
	''', '''
		a {
			content: 0 1 2 a;
		}
	'''

test "assign to edge item with negative number", ->
	assert.compileTo '''
		$list = 0 1 2;
		$list[-4] = a;
		a {
			content: $list;
		}
	''', '''
		a {
			content: a 0 1 2;
		}
	'''

test "assign to out-fo-range item with number", ->
	assert.compileTo '''
		$list = 0 1 2;
		$list[4] = a;
		a {
			content: $list;
		}
	''', '''
		a {
			content: 0 1 2 null a;
		}
	'''

test "assign to out-of-range item with negative number", ->
	assert.compileTo '''
		$list = 0 1 2;
		$list[-5] = a;
		a {
			content: $list;
		}
	''', '''
		a {
			content: a null 0 1 2;
		}
	'''

test "assign using assignment operation to list with number", ->
	assert.compileTo '''
		$list = 0 1;
		$list[0] += 1;
		a {
			content: $list;
		}
	''', '''
		a {
			content: 1 1;
		}
	'''

test "disallow assign using unsupported assignment operation to list with number", ->
	assert.failAt '''
		$list = 0% 1;
		$list[0] += a;
	''', { line: 2, column: 1 }

test "assign with range", ->
	assert.compileTo '''
		$list = 0 1 2;
		$list[1..2] = a;
		a {
			content: $list;
		}
	''', '''
		a {
			content: 0 a;
		}
	'''

test "assign with negative range", ->
	assert.compileTo '''
		$list = 0 1 2;
		$list[-3..-2] = a;
		a {
			content: $list;
		}
	''', '''
		a {
			content: a 2;
		}
	'''

test "assign with reversed range", ->
	assert.compileTo '''
		$list = 0 1 2;
		$list[1..0] = a b;
		a {
			content: $list;
		}
	''', '''
		a {
			content: b a 2;
		}
	'''

test "assign to partially out-of-range items with range", ->
	assert.compileTo '''
		$list = 0 1 2;
		$list[1..3] = a;
		a {
			content: $list;
		}
	''', '''
		a {
			content: 0 a;
		}
	'''

test "assign to edge items with range", ->
	assert.compileTo '''
		$list = 0 1 2;
		$list[3..4] = a;
		a {
			content: $list;
		}
	''', '''
		a {
			content: 0 1 2 a;
		}
	'''

test "assign to edge items with negative range", ->
	assert.compileTo '''
		$list = 0 1 2;
		$list[-5..-4] = a;
		a {
			content: $list;
		}
	''', '''
		a {
			content: a 0 1 2;
		}
	'''

test "assign to out-of-range items with range", ->
	assert.compileTo '''
		$list = 0 1 2;
		$list[4..5] = a;
		a {
			content: $list;
		}
	''', '''
		a {
			content: 0 1 2 null a;
		}
	'''

test "assign to out-of-range items with reversed range", ->
	assert.compileTo '''
		$list = 0 1 2;
		$list[5..4] = a b c;
		a {
			content: $list;
		}
	''', '''
		a {
			content: 0 1 2 null c b a;
		}
	'''

test "assign to out-of-range items with negative range", ->
	assert.compileTo '''
		$list = 0 1 2;
		$list[-6..-5] = a;
		a {
			content: $list;
		}
	''', '''
		a {
			content: a null 0 1 2;
		}
	'''

test "assign to out-of-range items with reversed negative range", ->
	assert.compileTo '''
		$list = 0 1 2;
		$list[-5..-6] = a b;
		a {
			content: $list;
		}
	''', '''
		a {
			content: b a null 0 1 2;
		}
	'''

test "assign to partially out-of-range items with range", ->
	assert.compileTo '''
		$list = 0 1 2;
		$list[-4..-2] = a;
		a {
			content: $list;
		}
	''', '''
		a {
			content: a 2;
		}
	'''

test "assign to item with empty exclusive range", ->
	assert.compileTo '''
		$list = 0 1 2;
		$list[2...2] = a;
		a {
			content: $list;
		}
	''', '''
		a {
			content: 0 1 a 2;
		}
	'''

test "assign to item with empty exclusive negative range", ->
	assert.compileTo '''
		$list = 0 1 2;
		$list[-3...-3] = a;
		a {
			content: $list;
		}
	''', '''
		a {
			content: a 0 1 2;
		}
	'''

test "assign to edge item with empty exclusive range", ->
	assert.compileTo '''
		$list = 0 1 2;
		$list[3...3] = a;
		a {
			content: $list;
		}
	''', '''
		a {
			content: 0 1 2 a;
		}
	'''

test "assign to edge item with empty exclusive negative range", ->
	assert.compileTo '''
		$list = 0 1 2;
		$list[-4...-4] = a;
		a {
			content: $list;
		}
	''', '''
		a {
			content: a null 0 1 2;
		}
	'''

test "assign to out-of-range item with empty exclusive range", ->
	assert.compileTo '''
		$list = 0 1 2;
		$list[4...4] = a;
		a {
			content: $list;
		}
	''', '''
		a {
			content: 0 1 2 null a;
		}
	'''

test "assign to out-of-range item with empty exclusive negative range", ->
	assert.compileTo '''
		$list = 0 1 2;
		$list[-5...-5] = a;
		a {
			content: $list;
		}
	''', '''
		a {
			content: a null null 0 1 2;
		}
	'''


test "assign to item in single-item list with number", ->
	assert.compileTo '''
		$list = [0];
		$list[0] = a;
		a {
			content: $list;
		}
	''', '''
		a {
			content: a;
		}
	'''

test "assign to edge item in single-item list with number", ->
	assert.compileTo '''
		$list = [0];
		$list[1] = a;
		a {
			content: $list;
		}
	''', '''
		a {
			content: 0 a;
		}
	'''

test "assign to edge item single-item list using list", ->
	assert.compileTo '''
		$list = [0];
		$list[1] = 1, 2;
		a {
			content: $list;
		}
	''', '''
		a {
			content: 0, 1, 2;
		}
	'''

test "assign to out-of-range item in single-item list using list", ->
	assert.compileTo '''
		$list = [0];
		$list[2] = 1, 2;
		a {
			content: $list;
		}
	''', '''
		a {
			content: 0, null, 1, 2;
		}
	'''

test "assign to edge item single-item list with negative number using list", ->
	assert.compileTo '''
		$list = [0];
		$list[-2] = 1, 2;
		a {
			content: $list;
		}
	''', '''
		a {
			content: 1, 2, 0;
		}
	'''

test "assign to out-of-range item in single-item list with negative number using list", ->
	assert.compileTo '''
		$list = [0];
		$list[-3] = 1, 2;
		a {
			content: $list;
		}
	''', '''
		a {
			content: 1, 2, null, 0;
		}
	'''

test "assign to empty list with number", ->
	assert.compileTo '''
		$list = [];
		$list[0] = a;
		a {
			content: $list;
		}
	''', '''
		a {
			content: a;
		}
	'''

test "assign to empty list with negative number", ->
	assert.compileTo '''
		$list = [];
		$list[-1] = a;
		a {
			content: $list;
		}
	''', '''
		a {
			content: a;
		}
	'''

test "assign to out-fo-range item in empty list with number", ->
	assert.compileTo '''
		$list = [];
		$list[1] = a;
		a {
			content: $list;
		}
	''', '''
		a {
			content: null a;
		}
	'''

test "assign to empty list with empty range", ->
	assert.compileTo '''
		$list = [];
		$list[0...0] = a;
		a {
			content: $list;
		}
	''', '''
		a {
			content: a;
		}
	'''

test "assign to out-fo-range item in empty list with empty range", ->
	assert.compileTo '''
		$list = [];
		$list[1...1] = a;
		a {
			content: $list;
		}
	''', '''
		a {
			content: null a;
		}
	'''

test "disallow assigning to value with member expression", ->
	assert.failAt '''
		$list = 0;
		$list[1] = a;
	''', { line: 2, column: 1 }

test "ignore assignment operation if assign to out-fo-range item with number", ->
	assert.compileTo '''
		$list = [];
		$list[0] += a;
		a {
			content: $list;
		}
	''', '''
		a {
			content: [];
		}
	'''

test "ignore assignment operation if assign to out-fo-range item with negative number", ->
	assert.compileTo '''
		$list = [];
		$list[-2] /= a;
		a {
			content: $list;
		}
	''', '''
		a {
			content: [];
		}
	'''

test "ignore assignment operation if assign with empty", ->
	assert.compileTo '''
		$list = [0];
		$list[0...0] %= a;
		a {
			content: $list;
		}
	''', '''
		a {
			content: 0;
		}
	'''

test "assign using multiple member expressions", ->
	assert.compileTo '''
		$list = [0 [1]];
		$list[1][0] += 1;
		a {
			content: $list;
		}
	''', '''
		a {
			content: 0 2;
		}
	'''

test "disallow assigning to range", ->
	assert.failAt '''
		$list = 1..3;
		$list[1] = a;
	''', { line: 2, column: 1 }

test "assign with variable", ->
	assert.compileTo '''
		$list = 0 1 2;
		$range = 0..1;
		$list[$range] = a;
		a {
			content: $list;
		}
	''', '''
		a {
			content: a 2;
		}
	'''