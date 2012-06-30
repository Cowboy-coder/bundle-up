fs = require 'fs'
mkdirp = require 'mkdirp'
async = require 'async'
stylus = require 'stylus'
{compile} = require './compiler'

class OnTheFlyCompiler
  constructor: (js, css, compilers) ->
    @js = js
    @css = css
    @compilers = compilers

    setImportFlag = (files) ->
      for file in files
        file._importChecked = false

    setImportFlag(@js.files)
    setImportFlag(@css.files)

  middleware: (req, res, next) =>
    if req.url.indexOf('.js') > -1
      for file, i in @js.files
        if req.url == file.url
          return @handleFile(file, (err) -> next(err))
        else
          return next() if i == (@js.files.length - 1)

    else if req.url.indexOf('.css') > -1
      for file, i in @css.files
        if req.url == file.url
          return @handleFile(file, (err) -> next(err)) if req.url == file.url
        else
          return next() if i == (@css.files.length - 1)
    return next()

  handleFile: (file, fn) =>
    if not file._importChecked
      @mapImports file, (err) =>
        return fn(err) if err?

        file._importChecked = true
        return @handleFile(file, fn)
      return

    # Check modified timestamp on file
    fs.stat file.origFile, (err, destStats) =>
      return fn(err) if err?

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
        , (err) ->
          return fn(err) if err?

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
      return fn(err) if err?
      compile @compilers, content, file.origFile, (err, newContent) =>
        return fn(err) if err?
        @writeToFile file.file, newContent, (err) ->
          return fn(err) if err?

          fs.stat file.origFile, (err, stats) ->
            return fn(err) if err?

            file._mtime = stats.mtime
            return fn()

  writeToFile: (file, content, fn) =>
    fs.writeFile file, content, 'utf8', (err) =>
      if err
        if err.code == 'ENOENT'
          splitted = file.split('/')
          mkdirp splitted.splice(0, splitted.length-1).join('/'), 0o0777, (err) =>
            return fn(err) if err?
            return @writeToFile(file, content, fn)
        else
          return fn(err)
      else
        return fn()

  mapImports: (file, fn) ->
    # Need to map imports for stylus files
    if file.origFile.indexOf('.styl') > -1
      fs.readFile file.origFile, 'utf8', (err, content) =>
        return fn(err) if err?
        style = @compilers.stylus(content, file.origFile)
        file._imports = []
        paths = style.options._imports = []
        style.render (err, css) ->
          async.forEach(paths, (path, cb) ->
            if path.path
              fs.stat path.path, (err, stats) ->
                return cb(err) if err?
                file._imports.push
                  file: path.path
                  mtime: stats.mtime
                cb()
            else
              cb()
          , (err) ->
            return fn(err)
          )
    else
      return fn()

module.exports = OnTheFlyCompiler
