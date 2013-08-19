assert = require './assert'

suite '@import'

test "string as url", ->
	assert.compileTo [
		'base.roo': '''
			body {
				margin: 0;
			}
		'''
		'''
			@import './base';
		'''
	], '''
		body {
			margin: 0;
		}
	'''

test "string starting with protocol as url", ->
	assert.compileTo '''
		@import 'http://example.com/style';
	''', '''
		@import 'http://example.com/style';
	'''

test "string ending with .css as url", ->
	assert.compileTo '''
		@import 'tabs.css';
	''', '''
		@import 'tabs.css';
	'''

test "url() as url", ->
	assert.compileTo '''
		@import url(base);
	''', '''
		@import url(base);
	'''

test "contain media query", ->
	assert.compileTo '''
		@import 'base' screen;
	''', '''
		@import 'base' screen;
	'''

test "contain media query list", ->
	assert.compileTo '''
		@import 'base' screen, print;
	''', '''
		@import 'base' screen, print;
	'''

test "recursively import", ->
	assert.compileTo [
		'reset.roo': '''
			body {
				margin: 0;
			}
		'''
		'button.roo': '''
			@import './reset';

			.button {
				display: inline-block;
			}
		'''
		'''
			@import './button';
		'''
	], '''
		body {
			margin: 0;
		}

		.button {
			display: inline-block;
		}
	'''

test "import same file multiple times", ->
	assert.compileTo [
		'reset.roo': '''
			body {
				margin: 0;
			}
		'''
		'button.roo': '''
			@import './reset';

			.button {
				display: inline-block;
			}
		'''
		'tabs.roo': '''
			@import './reset';

			.tabs {
				overflow: hidden;
			}
		'''
		'''
			@import './button';
			@import './tabs';
		'''
	], '''
		body {
			margin: 0;
		}

		.button {
			display: inline-block;
		}

		.tabs {
			overflow: hidden;
		}
	'''

test "recursively import files of the same directory", ->
	assert.compileTo [
		'tabs/tab.roo': '''
			.tab {
				float: left;
			}
		'''
		'tabs/index.roo': '''
			@import './tab';

			.tabs {
				overflow: hidden;
			}
		'''
		'''
			@import './tabs/index';
		'''
	], '''
		.tab {
			float: left;
		}

		.tabs {
			overflow: hidden;
		}
	'''

test "recursively import files of different directories", ->
	assert.compileTo [
		'reset.roo': '''
			body {
				margin: 0;
			}
		'''
		'tabs/index.roo': '''
			@import '../reset';

			.tabs {
				overflow: hidden;
			}
		'''
		'''
			@import './tabs/index';
		'''
	], '''
		body {
			margin: 0;
		}

		.tabs {
			overflow: hidden;
		}
	'''

test "import index.roo when importing a directory", ->
	assert.compileTo [
		'tabs/index.roo': '''
			.tabs {
				overflow: hidden;
			}
		'''
		'''
			@import './tabs';
		'''
	], '''
		.tabs {
			overflow: hidden;
		}
	'''

test "import file specified in package.json when importing a directory", ->
	assert.compileTo [
		'tabs/index.roo': '''
			.tabs {
				overflow: hidden;
			}
		'''
		'tabs/tab.roo': '''
			.tab {
				float: left;
			}
		'''
		'tabs/package.json': '''
			{ "main": "tab.roo" }
		'''
		'''
			@import './tabs';
		'''
	], '''
		.tab {
			float: left;
		}
	'''

test "import lib", ->
	assert.compileTo [
		'node_modules/tabs/index.roo': '''
			.tabs {
				overflow: hidden;
			}
		'''
		'''
			@import 'tabs';
		'''
	], '''
		.tabs {
			overflow: hidden;
		}
	'''

test "recursively find location when importing lib", ->
	assert.compileTo [
		'node_modules/button/index.roo': '''
			.button {
				display: inline-block;
			}
		'''
		'tabs/index.roo': '''
			@import 'button';

			.tabs {
				overflow: hidden;
			}
		'''
		'''
			@import './tabs';
		'''
	], '''
		.button {
			display: inline-block;
		}

		.tabs {
			overflow: hidden;
		}
	'''

test "importing file with variables in the path", ->
	assert.compileTo [
		'tabs.roo': '''
			.tabs {
				overflow: hidden;
			}
		'''
		'''
			$path = './tabs';
			@import $path;
		'''
	], '''
		.tabs {
			overflow: hidden;
		}
	'''

test "disallow importing file with syntax error", ->
	assert.failAt [
		'base.roo': '''
			body # {
				margin: 0;
			}
		'''
		'''
			@import './base';
		'''
	], {line: 1, column: 7, filename: 'base.roo'}

test "disallow importing file that doesn't exist", ->
	assert.failAt [
		'''
			@import './base';
		'''
	], {line: 1, column: 1}

test "nest in ruleset", ->
	assert.compileTo [
		'base.roo': '''
			body {
				margin: 0;
			}
		'''
		'''
			html {
				@import './base';
			}
		'''
	], '''
		html body {
			margin: 0;
		}
	'''

test "nest in @void", ->
	assert.compileTo [
		'base.roo': '''
			body {
				margin: 0;
			}
		'''
		'''
			@void {
				@import './base';
			}
		'''
	], ''