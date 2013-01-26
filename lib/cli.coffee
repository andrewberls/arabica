async  = require('async')
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
      console.error(clc.red('Directory not found: ' + dir));
      process.exit(1);

  config_path = "#{process.cwd()}/config.json"
  if (fs.existsSync(config_path))
    try
      # Read config JSON and supplement with default options
      config = _.defaults JSON.parse(fs.readFileSync(config_path, 'utf8')), {
        "out": "game.js"
        "uglify": true
        "paths": []
      }
      async.forEachSeries config.paths, parseConfigPath, (err) ->
        throw err if err

        # All files have been processed and added to our "global" `files` array.
        compile()
    catch err
      console.error clc.red('Something went wrong, please check your config.json syntax')
      process.exit(1)
  else
    console.error clc.red("No config.json file found in #{process.cwd()}")
    process.exit(1)


parseConfigPath = (path, callback) ->
  fs.exists path, (exists) ->
    if !exists
      console.warn clc.yellow("File #{path} doesn't exist")
      callback()
      return

    fs.stat path, (err, stats) ->
      throw err if err

      if stats.isFile()
        fileObj = {
          path: path,
          language: path.substring(path.lastIndexOf('.') + 1)
        }

        fs.readFile path, 'utf8', (err, content) ->
          callback(err) if err
          fileObj.content = content
          files.push(fileObj)
          callback()


compile = ->
  async.forEach files, (file, callback) ->
    if file.language != 'coffee'
      callback()
      return

    coffee = require('coffee-script')
    file.content = coffee.compile(file.content, { filename: file.path })
    callback()
  , (err) ->
    if err
      console.error clc.red("Converting #{err} to JavaScript failed.")
      process.exit(1);

    concatAndUglify()


concatAndUglify = ->
  async.reduce files, '', (memo, file, callback) ->
    callback(null, memo + file.content + '\n')
  , (err, combinedFiles) ->
    throw err if err

    if config.uglify
      uglify        = require('uglify-js')
      uglifiedFiles = uglify.minify(combinedFiles, {
        fromString: true
      }).code

      write(uglifiedFiles)
    else
      write(combinedFiles)


write = (content) ->
  fs.writeFile config.out, content, 'utf8', (err) ->
    if err
      console.error clc.red('An error occurred writing the output file.')
      process.exit(1)

    console.log clc.green("Finished compiling to #{config.out}")
