# roole-evaluator

Convert [Roole](http://roole.org/) AST to CSS AST.

It eliminates constructs that cannot exist in CSS (e.g., `@if`, `@for`, variables, etc).

## Example

```javascript
var parser = require('roole-parser');
var evaluator = require('roole-parser');

var ast = parser.parse('body { margin: 0 }');
evaluator.evaluate(ast).then(function (ast) {
	console.log(ast);
});
```

## API

```javascript
var promise = evaluator.evaluate(ast, [options]);
```

* `ast` - Roole AST
* `promise` - A promise whose fulfilling value is the CSS AST
* `options` - An object literal supporting these options:
	* `imports` (default: `{}`) - An object literal containing files to be imported, keys are file paths, values are the contents. When a imported file matches a file path, the content will be used directly, and no external request is generated.