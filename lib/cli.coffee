clc    = require('cli-color')
fs     = require('fs')
files  = []
config = {}

exports.build = (dir) ->
  _ = require('underscore')

  if (dir)
    try
      process.chdir(dir)
    catch err
      console.error clc.red('Directory not found: ' + dir)
      process.exit(1)

  config_path = "#{process.cwd()}/config.json"
  if fs.existsSync(config_path)
    try
      # Read config JSON and supplement with default options
      config = _.defaults JSON.parse(fs.readFileSync(config_path, 'utf8')), {
        "out": "game.js"
        "uglify": true
        "paths": []
      }

      # Compile over old file
      fs.unlinkSync(config.out) if fs.existsSync(config.out)

      for path in config.paths
        if !fs.existsSync(path)
          console.warn clc.yellow("File #{path} doesn't exist")
          callback()
          return

        if fs.statSync(path).isFile()
          fileObj = {
            path: path,
            language: path.substring(path.lastIndexOf('.') + 1)
            content: ''
          }
          fileObj.content = fs.readFileSync(path)
          files.push(fileObj)

      # All files have been processed and added to our "global" `files` array
      # Concatenate all coffeescripts, and write them along with any ordinary javascripts
      concatenate()
      compile()
      console.log clc.green("Successfully compiled to #{config.out}")
    catch err
      console.error clc.red('Something went wrong, please check your config.json syntax')
      process.exit(1)
  else
    console.error clc.red("No config.json file found in #{process.cwd()}")
    process.exit(1)


# Put any javascripts at the head of <config.out>.js, and concatenate coffeescripts
# to a temporary file for single compilation in compile()
concatenate = ->
  for file in files
    if file.language == "js"
      fs.appendFileSync(config.out, file.content)
    else if file.language == "coffee"
      fs.appendFileSync("__in.coffee", file.content)


compile = ->
  coffee = require('coffee-script')
  src    = coffee.compile(fs.readFileSync('__in.coffee').toString(), { bare: on })
  fs.appendFileSync(config.out, src)
  fs.unlinkSync('__in.coffee')
