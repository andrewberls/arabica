var fs = require('fs'),
    assert  = require('assert'),
    sys     = require('sys'),
    exec    = require('child_process').exec,
    arabica = require('../build/cli'); // TODO: this seems kind of strange

describe('Arabica', function() {
  before(function() {
    try {
      process.chdir('example');
      if (fs.existsSync('build.js')) fs.unlinkSync('build.js');
    } catch(err) {
      console.error("Error changing directories");
      process.exit(1);
    }
  });

  // Space out Arabica's output
  beforeEach(function() { console.log("") });

  var buildOutput = "var sayHello;\n\n"+
    "console.log(\"Hello from one.coffee!\");\n\n"+
    "sayHello(\"world\");\n\n"+
    "sayHello = function(str) {\n"+
    "  return console.log(\"Hello \" + str + \"!\");\n"+
    "};\n";

  after(function() {
    // Put things back to normal
    fs.writeFileSync('build.js', buildOutput);
  });

  describe('#build()', function() {
    it('creates the output file', function() {
      arabica.build()
      assert.equal( true, fs.existsSync('build.js') );
    });

    // TODO: this is probably the grossest to test this.
    // However, for a trivial example it'll do for now.
    it('concatenates files successfully', function() {
      var fileContents = fs.readFileSync('build.js').toString();
      assert.equal ( buildOutput, fileContents );
    });
  });

  describe('#clean()', function() {
    it('removes the build file', function() {
      if (fs.existsSync('build.js')) fs.unlinkSync('build.js');
      arabica.build();
      assert.equal( true, fs.existsSync('build.js') );
      arabica.clean();
      assert.equal( false, fs.existsSync('build.js') );
    });
  });
});
