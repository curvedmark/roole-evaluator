assert = require './assert'

suite '@import'

test "path", ->
	assert.compileTo {
		'/base.roo': '''
			body {
				margin: 0;
			}
		'''
		'/index.roo': '''
			@import './base.roo';
		'''
	}, '''
		body {
			margin: 0;
		}
	'''

test "url string starting with protocol", ->
	assert.compileTo '''
		@import 'http://example.com/style';
	''', '''
		@import 'http://example.com/style';
	'''

test "url string ending with .css", ->
	assert.compileTo {
		'/tabs.css': '''
			.tabs {
				content: "$tabs";
			}
		'''
		'/index.roo': '''
			@import 'tabs.css';
		'''
	}, '''
		.tabs {
			content: "$tabs";
		}
	'''

test "url string containing media query", ->
	assert.compileTo {
		'/base.roo': '''
			body { margin: 0 }
		'''
		'/index.roo': '''
			@import './base.roo' screen;
		'''
	}, '''
		@media screen {
			body {
				margin: 0;
			}
		}
	'''

test "url string ending with .css containing media query list", ->
	assert.compileTo {
		'/tabs.css': '''
			.tabs {
				content: "$tabs";
			}
		'''
		'/index.roo': '''
			@import './tabs.css' screen, print;
		'''
	}, '''
		@media screen, print {
			.tabs {
				content: "$tabs";
			}
		}
	'''

test "url using url()", ->
	assert.compileTo '''
		@import url(base);
	''', '''
		@import url(base);
	'''

test "recursively import", ->
	assert.compileTo {
		'/reset.roo': '''
			body {
				margin: 0;
			}
		'''
		'/button.roo': '''
			@import './reset.roo';

			.button {
				display: inline-block;
			}
		'''
		'/index.roo': '''
			@import './button.roo';
		'''
	}, '''
		body {
			margin: 0;
		}

		.button {
			display: inline-block;
		}
	'''

test "import same file multiple times", ->
	assert.compileTo {
		'/reset.roo': '''
			body {
				margin: 0;
			}
		'''
		'/button.roo': '''
			@import './reset.roo';

			.button {
				display: inline-block;
			}
		'''
		'/tabs.roo': '''
			@import './reset.roo';

			.tabs {
				overflow: hidden;
			}
		'''
		'/index.roo': '''
			@import './button.roo';
			@import './tabs.roo';
		'''
	}, '''
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
	assert.compileTo {
		'/tabs/tab.roo': '''
			.tab {
				float: left;
			}
		'''
		'/tabs/index.roo': '''
			@import './tab.roo';

			.tabs {
				overflow: hidden;
			}
		'''
		'/index.roo': '''
			@import './tabs/index.roo';
		'''
	}, '''
		.tab {
			float: left;
		}

		.tabs {
			overflow: hidden;
		}
	'''

test "recursively import files of different directories", ->
	assert.compileTo {
		'/reset.roo': '''
			body {
				margin: 0;
			}
		'''
		'/tabs/index.roo': '''
			@import '../reset.roo';

			.tabs {
				overflow: hidden;
			}
		'''
		'/index.roo': '''
			@import './tabs/index.roo';
		'''
	}, '''
		body {
			margin: 0;
		}

		.tabs {
			overflow: hidden;
		}
	'''

test "import index.roo when importing a directory", ->
	assert.compileTo {
		'/tabs/index.roo': '''
			.tabs {
				overflow: hidden;
			}
		'''
		'/index.roo': '''
			@import './tabs';
		'''
	}, '''
		.tabs {
			overflow: hidden;
		}
	'''

test "import directory when base is not the parent of current file", ->
	assert.compileTo { base: '/baz' }, {
		'/foo/bar/index.roo': '''
			.tabs {
				overflow: hidden;
			}
		'''
		'/index.roo': '''
			@import './foo/bar';
		'''
	}, '''
		.tabs {
			overflow: hidden;
		}
	'''

test "import file specified in package.json when importing a directory", ->
	assert.compileTo {
		'/tabs/index.roo': '''
			.tabs {
				overflow: hidden;
			}
		'''
		'/tabs/tab.roo': '''
			.tab {
				float: left;
			}
		'''
		'/tabs/package.json': '''
			{ "main": "tab.roo" }
		'''
		'/index.roo': '''
			@import './tabs';
		'''
	}, '''
		.tab {
			float: left;
		}
	'''

test "force importing a directory when path ends with /", ->
	assert.compileTo {
		'/tabs.roo/index.roo': '''
			.tabs {
				overflow: hidden;
			}
		'''
		'/tabs.roo': '''
			.tabs {
				overflow: auto;
			}
		'''
		'/index.roo': '''
			@import './tabs.roo/';
		'''
	}, '''
		.tabs {
			overflow: hidden;
		}
	'''

test "import lib", ->
	assert.compileTo {
		'/node_modules/tabs/index.roo': '''
			.tabs {
				overflow: hidden;
			}
		'''
		'/index.roo': '''
			@import 'tabs';
		'''
	}, '''
		.tabs {
			overflow: hidden;
		}
	'''

test "recursively find location when importing lib", ->
	assert.compileTo {
		'/node_modules/button/index.roo': '''
			.button {
				display: inline-block;
			}
		'''
		'/tabs/index.roo': '''
			@import 'button';

			.tabs {
				overflow: hidden;
			}
		'''
		'/index.roo': '''
			@import './tabs';
		'''
	}, '''
		.button {
			display: inline-block;
		}

		.tabs {
			overflow: hidden;
		}
	'''

test "importing file with variables in the path", ->
	assert.compileTo {
		'/tabs.roo': '''
			.tabs {
				overflow: hidden;
			}
		'''
		'/index.roo': '''
			$path = './tabs.roo';
			@import $path;
		'''
	}, '''
		.tabs {
			overflow: hidden;
		}
	'''

test "disallow importing file with syntax error", ->
	assert.failAt {
		'/base.roo': '''
			body # {
				margin: 0;
			}
		'''
		'/index.roo': '''
			@import './base.roo';
		'''
	}, {line: 1, column: 7, filename: '/base.roo'}

test "disallow importing file that doesn't exist", ->
	assert.failAt '''
		@import './base';
	''', {line: 1, column: 1}

test "nest in ruleset", ->
	assert.compileTo {
		'/base.roo': '''
			body {
				margin: 0;
			}
		'''
		'/index.roo': '''
			html {
				@import './base.roo';
			}
		'''
	}, '''
		html body {
			margin: 0;
		}
	'''

test "nest in @void", ->
	assert.compileTo {
		'/base.roo': '''
			body {
				margin: 0;
			}
		'''
		'/index.roo': '''
			@void {
				@import './base.roo';
			}
		'''
	}, ''