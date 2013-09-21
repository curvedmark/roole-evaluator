assert = require './assert'

suite 'Url'

test "relative url", ->
	assert.compileTo {
		'/tabs/index.roo': '''
			.tabs {
				background: url("bg.png")
			}
		'''
		'/index.roo': '''
			@import './tabs';

			body {
				background: url("bg.png")
			}
		'''
	}, '''
		.tabs {
			background: url("bg.png");
		}

		body {
			background: url("bg.png");
		}
	'''

test "prefixed relative url", ->
	assert.compileTo {
		'/tabs/index.roo': '''
			.tabs {
				background: url("./bg.png")
			}
		'''
		'/index.roo': '''
			@import './tabs';

			body {
				background: url("./bg.png")
			}
		'''
	}, '''
		.tabs {
			background: url("tabs/bg.png");
		}

		body {
			background: url("bg.png");
		}
	'''

test "unquoted relative url", ->
	assert.compileTo {
		'/tabs/index.roo': '''
			.tabs {
				background: url(bg.png)
			}
		'''
		'/index.roo': '''
			@import './tabs';

			body {
				background: url(bg.png)
			}
		'''
	}, '''
		.tabs {
			background: url(bg.png);
		}

		body {
			background: url(bg.png);
		}
	'''

test "prefixed unquoted relative url", ->
	assert.compileTo {
		'/tabs/index.roo': '''
			.tabs {
				background: url(../bg.png)
			}
		'''
		'/index.roo': '''
			@import './tabs';

			body {
				background: url(./bg.png)
			}
		'''
	}, '''
		.tabs {
			background: url(bg.png);
		}

		body {
			background: url(bg.png);
		}
	'''

test "absolute url", ->
	assert.compileTo {
		'/tabs/index.roo': '''
			.tabs {
				background: url("/bg.png")
			}
		'''
		'/index.roo': '''
			@import './tabs';

			body {
				background: url("/bg.png")
			}
		'''
	}, '''
		.tabs {
			background: url("/bg.png");
		}

		body {
			background: url("/bg.png");
		}
	'''

test "unquoted absolute url", ->
	assert.compileTo {
		'/tabs/index.roo': '''
			.tabs {
				background: url(/bg.png)
			}
		'''
		'/index.roo': '''
			@import './tabs';

			body {
				background: url(/bg.png)
			}
		'''
	}, '''
		.tabs {
			background: url(/bg.png);
		}

		body {
			background: url(/bg.png);
		}
	'''

test "url starting with protocol", ->
	assert.compileTo {
		'/tabs/index.roo': '''
			.tabs {
				background: url("http://example.com/bg.png")
			}
		'''
		'/index.roo': '''
			@import './tabs';

			body {
				background: url("//example.com/bg.png")
			}
		'''
	}, '''
		.tabs {
			background: url("http://example.com/bg.png");
		}

		body {
			background: url("//example.com/bg.png");
		}
	'''

test "relative url in @import", ->
	assert.compileTo {
		'/tabs/index.roo': '''
			@import "tabs.css";
		'''
		'/index.roo': '''
			@import './tabs';

			@import "base.css";
		'''
	}, '''
		@import "tabs.css";

		@import "base.css";
	'''

test "prefixed relative url in @import", ->
	assert.compileTo {
		'/tabs/index.roo': '''
			@import "./tabs.css";
		'''
		'/index.roo': '''
			@import './tabs';

			@import "base.css";
		'''
	}, '''
		@import "tabs/tabs.css";

		@import "base.css";
	'''

test "absolute url in @import", ->
	assert.compileTo {
		'/tabs/index.roo': '''
			@import "/tabs.css";
		'''
		'/index.roo': '''
			@import './tabs';

			@import "/base.css";
		'''
	}, '''
		@import "/tabs.css";

		@import "/base.css";
	'''

test "variable as url", ->
	assert.compileTo '''
		$url = 'bg.png';
		a {
			content: url($url);
		}
	''', '''
		a {
			content: url('bg.png');
		}
	'''

test "disallow invalid url value", ->
	assert.failAt '''
		$url = 0 1;
		a {
			content: url($url);
		}
	''', { line: 3, column: 15 }