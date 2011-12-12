crypto = require 'crypto'
path = require 'path'
compiler = require './compiler'
fs = require 'fs'
{writeToFile, normalizeUrl} = require './helpers'

class Bundle
  constructor: (@options) ->
    @options.staticRoot = path.normalize(@options.staticRoot)
    @files = []

  # Gets relative path from staticRoot. If the
  # file passed in resides in another folder
  # the path returned is relative to the
  # root of the application
  _getRelativePath: (file) =>
    relativePath = ''
    for char, i in file
      if @options.staticRoot[i] == file[i]
        continue
      else
        relativePath = file.substring(i)
        break
    return relativePath

  # 
  # Determines based on file extension 
  # if the file needs to get compiled
  #
  _needsCompiling: (file) ->
    fileExt = file.split('.')
    fileExt = fileExt[fileExt.length - 1]
    return  fileExt != 'js' and fileExt != 'css'


  addFile:(file) =>
    file = path.normalize(file)
    relativeFile = @_getRelativePath(file)
    origFile = file
    needsCompiling = false

    # Determine if we need to copy/compile
    # the file into the staticRoot folder
    if (file.indexOf(@options.staticRoot) == -1 or @_needsCompiling(file))
      writeTo = path.normalize(@_convertFilename(@options.staticRoot + '/generated/' + relativeFile))
      needsCompiling = true
      file = writeTo
      relativeFile = @_getRelativePath(file)

    url = @options.staticUrlRoot + relativeFile

    url = normalizeUrl(url)
    @files.push
      url: url
      file: file
      origFile: origFile
      needsCompiling: needsCompiling

  toBundle: (filename) =>
    str = ''
    for file in @files
      @_compile(file.origFile, file.file)
      str += fs.readFileSync(file.file, 'utf-8').trim('\n') + '\n'

    str = @minify(str)
    hash = crypto.createHash('md5').update(str).digest('hex')
    filename = "#{hash.substring(0, 7)}_#{filename}"


    writeToFile("#{@options.staticRoot}generated/bundle/#{filename}", str)
    return filename


  _compile: (file, writeTo) ->
    compiler.compileFile(file, (err, content) ->
      writeToFile(writeTo, content)
    )
    return writeTo

module.exports = Bundle
