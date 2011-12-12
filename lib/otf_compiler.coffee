fs = require 'fs'
mkdirp = require 'mkdirp'
async = require 'async'
stylus = require 'stylus'
{compile, stylusCompile} = require './compiler'

class OnTheFlyCompiler
  constructor: (js, css) ->
    @js = js
    @css = css

    @mapImports(@js.files)
    @mapImports(@css.files)


  middleware: (req, res, next) =>
    if req.url.indexOf('.js') > -1
      for file, i in @js.files
        if req.url == file.url
          return @handleFile(file, -> next())
        else
          return next() if i == (@js.files.length - 1)

    else if req.url.indexOf('.css') > -1
      for file, i in @css.files
        if req.url == file.url
          return @handleFile(file, -> next()) if req.url == file.url
        else
          return next() if i == (@css.files.length - 1)
    else
      return next()

  handleFile: (file, fn) =>
    # Check modified timestamp on file
    fs.stat file.origFile, (err, destStats) =>
      if not file._mtime
        return @compileFile(file, fn)
      if file._mtime < destStats.mtime
        return @compileFile(file, fn)

      # Check modified timestamps on imports
      else if file._imports?
        changed = []
        compileFile = @compileFile
        async.forEach(file._imports, (importedFile, cb) =>
          fs.stat importedFile.file, (err, stats) =>
            return cb(err) if err?
            # One of the imported files changed
            if importedFile.mtime < stats.mtime
              importedFile.mtime = stats.mtime
              changed.push importedFile
            return cb()
        ,  ->
          if changed.length > 0
            return compileFile(file, fn)
          else
            return fn()
        )
      else
        fn()

  compileFile: (file, fn) =>
    return fn() unless file.needsCompiling

    fs.readFile file.origFile, 'utf8', (err, content) =>
      compile content, file.origFile, (err, newContent) =>
        @writeToFile file.file, newContent, ->
          fs.stat file.origFile, (err, stats) ->
            file._mtime = stats.mtime
            return fn()

  writeToFile: (file, content, fn) =>
    fs.writeFile file, content, 'utf8', (err) =>
      if err
        if err.code == 'ENOENT'
          splitted = file.split('/')
          mkdirp splitted.splice(0, splitted.length-1).join('/'), 0777, (err) =>
            if err?
              console.log err
            else
              return @writeToFile(file, content, fn)
        else
          console.log err
      else
        return fn()

  mapImports: (files) ->
    async.forEach(files, (file, cb) ->
      # Need to map imports for stylus files
      if file.origFile.indexOf('.styl') > -1
        fs.readFile file.origFile, 'utf8', (err, content) ->
          console.log err if err?
          style = stylusCompile(content, file.origFile)
          file._imports = []
          paths = style.options._imports = []
          style.render (err, css) ->
            console.log err if err?
            for path in paths
              if path.path
                fs.stat path.path, (err, stats) ->
                  console.log if err?
                  file._imports.push
                    file: path.path
                    mtime: stats.mtime
                  cb()
              else
                cb()
    , ->
      # All complete
    )

module.exports = OnTheFlyCompiler
