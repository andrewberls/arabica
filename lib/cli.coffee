color  = require('cli-color')
fs     = require('fs')
files  = []
config = {}


# Return the contents of config.json, or exit with an error if it doesn't exist
read_config = ->
  config_path = "#{process.cwd()}/config.json"
  if fs.existsSync(config_path)
    try
      return JSON.parse(fs.readFileSync(config_path, 'utf8'));
    catch err
      process.exit(1)
  else
    console.error color.red("No config.json file found in #{process.cwd()}")
    process.exit(1)


# Concatenate and compile the project at <dir>, using options specified in config.json
# Options:
#   paths: An array of file paths (.js or .coffee)
#   out: The filename to output to
#   uglify: Boolean indicating whether or not to minify output with Uglify.js
exports.build = (dir) ->
  _ = require('underscore')

  if (dir)
    try
      process.chdir(dir)
    catch err
      console.error color.red("Directory not found: #{dir}")
      process.exit(1)

  # Read config JSON and supplement with default options
  config = _.defaults read_config(), {
    "out": "build.js"
    "uglify": true
    "paths": []
  }

  # Compile over old file
  fs.unlinkSync(config.out) if fs.existsSync(config.out)

  for path in config.paths
    if !fs.existsSync(path)
      console.warn color.yellow("File #{path} doesn't exist, skipping")
      continue

    if fs.statSync(path).isFile()
      fileObj = {
        path: path,
        language: path.substring(path.lastIndexOf('.') + 1)
        content: ''
      }
      fileObj.content = fs.readFileSync(path)
      files.push(fileObj)

  # All files have been processed and added to the global files array
  # Concatenate all coffeescripts, and write them along with any ordinary javascripts
  concatenate()
  compile()
  console.log color.green("Successfully compiled to #{config.out}")


# Put any javascripts at the head of the output file, and concatenate coffeescripts
# to a temporary file for single compilation in compile()
concatenate = ->
  for file in files
    outfile = switch file.language
      when "js"     then config.out
      when "coffee" then "__in.coffee"
    fs.appendFileSync(outfile, file.content)


# Compile all concatenated coffeescripts and append to the output file,
# minifying if specified in config
compile = ->
  coffee = require('coffee-script')
  output = coffee.compile(fs.readFileSync('__in.coffee').toString(), { bare: on })

  if config.uglify == true
    UglifyJS = require("uglify-js")
    output   = UglifyJS.minify(output, { fromString: true }).code

  fs.appendFileSync(config.out, output)
  fs.unlinkSync('__in.coffee')


# Remove the output file specified in config.json
exports.clean = ->
  config = read_config()

  if fs.existsSync(config.out)
    fs.unlinkSync(config.out)
    console.log color.green("Removed #{config.out}.")
  else
    console.warn color.yellow("Nothing to do here (file not found: #{config.out})")
