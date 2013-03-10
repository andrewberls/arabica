# Arabica

Arabica is a simple tool for building CoffeeScript/JavaScript projects. It will concatenate and compile multiple .coffee/.js files into a single output, optionally minified using [UglifyJS](https://github.com/mishoo/UglifyJS).

## Configuration
Project options are specified in `arabica.json`, located at the root of your project.

```json
{
  "paths": [
      "src/lib/underscore.min.js",
      "src/one.coffee",
      "src/two.coffee",
      "src/three.coffee",
  ],
  "out": "build.min.js",
  "uglify": true
}
```

## Usage
`arabica build DIRECTORY` - Build the project using the `arabica.json` file located at `DIRECTORY` (defaults to current directory)

`arabica clean` - Removes the output file specified in `arabica.json`

## Example
There is a simple example set up in the [example/ directory](https://github.com/andrewberls/arabica/tree/master/example).

## Installation
Arabica is distributed as an [npm](http://npmjs.org/) package. To install, type
```
$ npm install arabica -g
```
This will install the `arabica` executable on your system.

## License
Arabica is licensed under MIT. For details, see the [LICENSE file](https://github.com/andrewberls/arabica/blob/master/LICENSE).
