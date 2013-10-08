assert = require './assert'

suite 'scope'

test "ruleset creates new scope", ->
	assert.compileTo '''
		$width = 980px;
		body {
			$width = 500px;
		}
		html {
			width: $width;
		}
	''', '''
		html {
			width: 980px;
		}
	'''

test "@media creates new scope", ->
	assert.compileTo '''
		$width = 980px;

		@media screen {
			$width = 500px;
		}

		body {
			width: $width;
		}
	''', '''
		body {
			width: 980px;
		}
	'''

test "@import does not create new scope", ->
	assert.compileTo {
		'/base.roo': '''
			$width = 500px;
		'''
		'/index.roo': '''
			$width = 980px;

			@import './base.roo';

			body {
				width: $width;
			}
		'''
	}, '''
		body {
			width: 500px;
		}
	'''

test "importing file expose variables", ->
	assert.compileTo {
		'/base.roo': '''
			body {
				width: $width;
			}
		'''
		'/index.roo': '''
			$width = 980px;
			@import './base.roo';
		'''
	}, '''
		body {
			width: 980px;
		}
	'''

test "@void creates new scope", ->
	assert.compileTo '''
		$width = 100px;

		@void {
			$width = 50px;
		}

		body {
			width: $width;
		}
	''', '''
		body {
			width: 100px;
		}
	'''

test "@block creates new scope", ->
	assert.compileTo '''
		$width = 980px;

		@block {
			$width = 500px;
		}

		body {
			width: $width;
		}
	''', '''
		body {
			width: 980px;
		}
	'''

test "@if creates new scope", ->
	assert.compileTo '''
		$width = 980px;

		@if true {
			$width = 500px;
		}

		body {
			width: $width;
		}
	''', '''
		body {
			width: 980px;
		}
	'''

test "@for creates new scope", ->
	assert.compileTo '''
		$width = 980px;

		@for $i in 1 {
			$width = 500px;
		}

		body {
			width: $width;
		}
	''', '''
		body {
			width: 980px;
		}
	'''

test "@keyframes creates new scope", ->
	assert.compileTo '''
		$width = 980px;

		@-webkit-keyframes name {
			$width = 400px;

			from {
				$width = 200px;
			}
			to {
				width: $width;
			}
		}

		body {
			width: $width;
		}
	''', '''
		@-webkit-keyframes name {
			to {
				width: 400px;
			}
		}

		body {
			width: 980px;
		}
	'''

test "@page creates new scope", ->
	assert.compileTo '''
		$width = 980px;

		@page {
			$width = 500px;
		}

		body {
			width: $width;
		}
	''', '''
		body {
			width: 980px;
		}
	'''

test "@font-face creates new scope", ->
	assert.compileTo '''
		$width = 980px;

		@font-face {
			$width = 500px;
		}

		body {
			width: $width;
		}
	''', '''
		body {
			width: 980px;
		}
	'''