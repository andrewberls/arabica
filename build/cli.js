(function() {
  var chdir, color, compile, concatenate, config, files, fs, read_config;

  color = require('cli-color');

  fs = require('fs');

  files = [];

  config = {};

  chdir = function(dir) {
    try {
      return process.chdir(dir);
    } catch (err) {
      console.error(color.red("Directory not found: " + dir + " in " + (process.cwd())));
      return process.exit(1);
    }
  };

  read_config = function() {
    var path;
    path = "" + (process.cwd()) + "/arabica.json";
    if (fs.existsSync(path)) {
      try {
        return JSON.parse(fs.readFileSync(path, 'utf8'));
      } catch (err) {
        console.error(color.red("An error occured trying to parse arabica.json: " + err));
        return process.exit(1);
      }
    } else {
      console.error(color.red("No arabica.json file found in " + (process.cwd())));
      return process.exit(1);
    }
  };

  exports.build = function(dir) {
    var fileObj, path, _, _i, _len, _ref;
    if (dir == null) {
      dir = null;
    }
    _ = require('underscore');
    if (dir != null) {
      chdir(dir);
    }
    config = _.defaults(read_config(), {
      "out": "build.js",
      "uglify": true,
      "paths": []
    });
    if (fs.existsSync(config.out)) {
      fs.unlinkSync(config.out);
    }
    _ref = config.paths;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      path = _ref[_i];
      if (!fs.existsSync(path)) {
        console.warn(color.yellow("File " + path + " doesn't exist, skipping"));
        continue;
      }
      if (fs.statSync(path).isFile()) {
        fileObj = {
          path: path,
          language: path.substring(path.lastIndexOf('.') + 1),
          content: ''
        };
        fileObj.content = fs.readFileSync(path);
        files.push(fileObj);
      }
    }
    concatenate();
    compile();
    return console.log(color.green("Successfully compiled " + (process.cwd()) + "/" + config.out));
  };

  concatenate = function() {
    var file, outfile, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = files.length; _i < _len; _i++) {
      file = files[_i];
      outfile = (function() {
        switch (file.language) {
          case "js":
            return config.out;
          case "coffee":
            return "__in.coffee";
        }
      })();
      _results.push(fs.appendFileSync(outfile, file.content));
    }
    return _results;
  };

  compile = function() {
    var UglifyJS, coffee, output;
    try {
      coffee = require('coffee-script');
      output = coffee.compile(fs.readFileSync('__in.coffee').toString());
      if (config.uglify === true) {
        UglifyJS = require("uglify-js");
        output = UglifyJS.minify(output, {
          fromString: true
        }).code;
      }
      return fs.appendFileSync(config.out, output);
    } finally {
      fs.unlinkSync('__in.coffee');
    }
  };

  exports.clean = function(dir) {
    if (dir == null) {
      dir = null;
    }
    if (dir != null) {
      chdir(dir);
    }
    config = read_config();
    if (fs.existsSync(config.out)) {
      fs.unlinkSync(config.out);
      return console.log(color.green("Removed " + (process.cwd()) + "/" + config.out + "."));
    } else {
      return console.warn(color.yellow("Nothing to do here (file not found: " + (process.cwd()) + "/" + config.out + ")"));
    }
  };

}).call(this);
