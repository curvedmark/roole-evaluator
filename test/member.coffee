assert = require './assert'

suite 'member'

test "access using number", ->
	assert.compileTo '''
		a {
			content: (0 1 2)[2];
		}
	''', '''
		a {
			content: 2;
		}
	'''

test "access using negative number", ->
	assert.compileTo '''
		a {
			content: (0 1 2)[-3];
		}
	''', '''
		a {
			content: 0;
		}
	'''

test "access out-of-range item using number", ->
	assert.compileTo '''
		a {
			content: [0 1 2][3];
		}
	''', '''
		a {
			content: null;
		}
	'''

test "access out-of-range item using negative number", ->
	assert.compileTo '''
		a {
			content: (0 1 2)[-4];
		}
	''', '''
		a {
			content: null;
		}
	'''

test "access value using number", ->
	assert.compileTo '''
		a {
			content: 1[0];
		}
	''', '''
		a {
			content: null;
		}
	'''

test "access value using negative number", ->
	assert.compileTo '''
		a {
			content: 1[-1];
		}
	''', '''
		a {
			content: null;
		}
	'''

test "access using range", ->
	assert.compileTo '''
		a {
			content: (0 1 2)[1..2];
		}
	''', '''
		a {
			content: 1 2;
		}
	'''

test "access using reversed range", ->
	assert.compileTo '''
		a {
			content: (0 1 2)[2..1];
		}
	''', '''
		a {
			content: 2 1;
		}
	'''

test "access using oversized range", ->
	assert.compileTo '''
		a {
			content: (0 1 2)[1..3];
		}
	''', '''
		a {
			content: 1 2;
		}
	'''

test "access using oversized reversed range", ->
	assert.compileTo '''
		a {
			content: (0 1 2)[3..1];
		}
	''', '''
		a {
			content: 2 1;
		}
	'''

test "access using one number range", ->
	assert.compileTo '''
		a {
			content: (0 1 2)[1..1][0];
		}
	''', '''
		a {
			content: 1;
		}
	'''

test "access using empty range", ->
	assert.compileTo '''
		a {
			content: (0 1 2)[1...1];
		}
	''', '''
		a {
			content: [];
		}
	'''

test "access using positive to negative single-item range", ->
	assert.compileTo '''
		a {
			content: (0 1 2)[1..-2];
		}
	''', '''
		a {
			content: 1;
		}
	'''

test "access using single-item exclusive range", ->
	assert.compileTo '''
		a {
			content: (0 1 2)[1...2];
		}
	''', '''
		a {
			content: 1;
		}
	'''

test "access using single-item reversed exclusive range", ->
	assert.compileTo '''
		a {
			content: (0 1 2)[1...-3];
		}
	''', '''
		a {
			content: 1;
		}
	'''

test "access using out-of-range range", ->
	assert.compileTo '''
		a {
			content: (0 1 2)[3..4];
		}
	''', '''
		a {
			content: [];
		}
	'''

test "access using out-of-range reversed range", ->
	assert.compileTo '''
		a {
			content: (0 1 2)[4..3];
		}
	''', '''
		a {
			content: [];
		}
	'''

test "access using negative range", ->
	assert.compileTo '''
		a {
			content: (0 1 2)[-2..-1];
		}
	''', '''
		a {
			content: 1 2;
		}
	'''

test "access using negative to positive range", ->
	assert.compileTo '''
		a {
			content: (0 1 2)[-2..2];
		}
	''', '''
		a {
			content: 1 2;
		}
	'''

test "access using positive to negative range", ->
	assert.compileTo '''
		a {
			content: (0 1 2)[1..-1];
		}
	''', '''
		a {
			content: 1 2;
		}
	'''

test "access using reversed negative range", ->
	assert.compileTo '''
		a {
			content: (0 1 2)[-1..-2];
		}
	''', '''
		a {
			content: 2 1;
		}
	'''

test "access using reversed negative to positive range", ->
	assert.compileTo '''
		a {
			content: (0 1 2)[-1..1];
		}
	''', '''
		a {
			content: 2 1;
		}
	'''

test "access using reversed positive to negative range", ->
	assert.compileTo '''
		a {
			content: (0 1 2)[2..-2];
		}
	''', '''
		a {
			content: 2 1;
		}
	'''

test "access using invalid type", ->
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

test "access range using number", ->
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

test "access range using range", ->
	assert.compileTo '''
		a {
			content: (1..4)[1..2];
		}
	''', '''
		a {
			content: 2 3;
		}
	'''

test "access empty list using number", ->
	assert.compileTo '''
		a {
			content: [][0];
		}
	''', '''
		a {
			content: null;
		}
	'''

test "disallow assigning to null", ->
	assert.failAt '''
		$list = null;
		$list[0] = a;
	''', { line: 2, column: 1 }

test "disallow assigning to non-list", ->
	assert.failAt '''
		$list = 0;
		$list[1] = a;
	''', { line: 2, column: 1 }

test "disallow assigning to list using invalid type", ->
	assert.failAt '''
		$list = 0 1 2;
		$list[null] = a;
	''', { line: 2, column: 7 }

test "disallow assigning to range", ->
	assert.failAt '''
		$list = 1..3;
		$list[1] = a;
	''', { line: 2, column: 1 }

test "assign using number", ->
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

test "assign using negative number", ->
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

test "assign to edge item using number", ->
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

test "assign to edge item using negative number", ->
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

test "assign to out-fo-range item using number", ->
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

test "assign to out-of-range item using negative number", ->
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

test "assign using assignment operation to list using number", ->
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

test "assign using := to list using number", ->
	assert.compileTo '''
		$list = 0 1;
		$list[0] := 1;
		a {
			content: $list;
		}
	''', '''
		a {
			content: 1 1;
		}
	'''

test "disallow assigning using unsupported assignment operation", ->
	assert.failAt '''
		$list = 0% 1;
		$list[0] += a;
	''', { line: 2, column: 1 }

test "assign using range", ->
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

test "assign using negative range", ->
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

test "assign using reversed range", ->
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

test "assign using oversized range", ->
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

test "assign to edge items using range", ->
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

test "assign to edge items using negative range", ->
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

test "assign to out-of-range items using range", ->
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

test "assign to out-of-range items using reversed range", ->
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

test "assign to out-of-range items using negative range", ->
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

test "assign to out-of-range items using reversed negative range", ->
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

test "assign to partially out-of-range items using range", ->
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

test "assign to item using empty range", ->
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

test "assign to item using empty negative range", ->
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

test "assign to edge item using empty range", ->
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

test "assign to edge item using empty negative range", ->
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

test "assign to out-of-range item using empty range", ->
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

test "assign to out-of-range item using empty negative range", ->
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

test "assign to item in single-item list using number", ->
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

test "assign to edge item in single-item list using number", ->
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

test "assign to edge item single-item list using negative number with list", ->
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

test "assign to out-of-range item in single-item list using negative number with list", ->
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

test "assign to edge item in empty list using number", ->
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

test "assign to edge item in empty list using negative number", ->
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

test "assign to out-fo-range item in empty list using number", ->
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

test "assign to out-fo-range item in empty list using negative number", ->
	assert.compileTo '''
		$list = [];
		$list[-2] = a;
		a {
			content: $list;
		}
	''', '''
		a {
			content: a null;
		}
	'''

test "assign to edge item in empty list using empty range", ->
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

test "assign to out-fo-range item in empty list using empty range", ->
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

test "ignore assignment operation if assign to out-fo-range item using number", ->
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

test "ignore assignment operation if assign to out-fo-range item using negative number", ->
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

test "ignore assignment operation if assign using empty range", ->
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

test "assign with range contained in a list", ->
	assert.compileTo '''
		$list = 0 1 2;
		$ranges = [0..1];
		$list[$ranges[0]] = a;
		a {
			content: $list;
		}
	''', '''
		a {
			content: a 2;
		}
	'''

test "assign to mix-separated list using number", ->
	assert.compileTo '''
		$list = 0 1, 2;
		$list[3] = a;
		a {
			content: $list;
		}
	''', '''
		a {
			content: 0 1, 2, a;
		}
	'''

test "assign to mix-separated list using negative number", ->
	assert.compileTo '''
		$list = 0, 1 2;
		$list[-5] = a;
		a {
			content: $list;
		}
	''', '''
		a {
			content: a, null, 0, 1 2;
		}
	'''

test "assign to single-item list using number", ->
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

test "assign to single-item list using negative number", ->
	assert.compileTo '''
		$list = [0];
		$list[-3] = a;
		a {
			content: $list;
		}
	''', '''
		a {
			content: a null 0;
		}
	'''

test "assign to single-item list using number with mix-separated list", ->
	assert.compileTo '''
		$list = [0];
		$list[2] = a, b c;
		a {
			content: $list;
		}
	''', '''
		a {
			content: 0, null, a, b c;
		}
	'''

test "assign to single-item list with negative number using mix-separated list", ->
	assert.compileTo '''
		$list = [0];
		$list[-2] = a b, c;
		a {
			content: $list;
		}
	''', '''
		a {
			content: a b, c, 0;
		}
	'''

test "assign to mix-separated list using empty range", ->
	assert.compileTo '''
		$list = 0, 1 2;
		$list[-4...-4] = a b;
		a {
			content: $list;
		}
	''', '''
		a {
			content: a b null 0, 1 2;
		}
	'''

test "assign to nested mix-separated list using number", ->
	assert.compileTo '''
		$list = 0 [1, 2];
		$list[2] = a;
		a {
			content: $list;
		}
	''', '''
		a {
			content: 0 1, 2 a;
		}
	'''

test "assign to nested mix-separated list using negative number", ->
	assert.compileTo '''
		$list = [[1, 2]];
		$list[0...0] = a;
		a {
			content: $list;
		}
	''', '''
		a {
			content: a 1, 2;
		}
	'''

test "assign with empty list", ->
	assert.compileTo '''
		$list = [1 2 3];
		$list[1] = [];
		a {
			content: $list;
		}
	''', '''
		a {
			content: 1 3;
		}
	'''

test "assign to start item with empty list", ->
	assert.compileTo '''
		$list = [1 2 3];
		$list[0] = [];
		a {
			content: $list;
		}
	''', '''
		a {
			content: 2 3;
		}
	'''

test "assign to end item with empty list", ->
	assert.compileTo '''
		$list = [1 2 3];
		$list[2] = [];
		a {
			content: $list;
		}
	''', '''
		a {
			content: 1 2;
		}
	'''

test "assign to out-fo-range item with empty list", ->
	assert.compileTo '''
		$list = [1 2];
		$list[2] = [];
		a {
			content: $list;
		}
	''', '''
		a {
			content: 1 2;
		}
	'''

test "assign to out-fo-range item using negative number with empty list", ->
	assert.compileTo '''
		$list = [1 2];
		$list[-3] = [];
		a {
			content: $list;
		}
	''', '''
		a {
			content: 1 2;
		}
	'''

test "assign using empty range with empty list", ->
	assert.compileTo '''
		$list = [1 2];
		$list[1...1] = [];
		a {
			content: $list;
		}
	''', '''
		a {
			content: 1 2;
		}
	'''