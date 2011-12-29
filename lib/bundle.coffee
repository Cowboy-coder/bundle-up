crypto = require 'crypto'
path = require 'path'
compiler = require './compiler'
fs = require 'fs'
{writeToFile, normalizeUrl} = require './helpers'

class Bundle
  constructor: (@options) ->
    @options.staticRoot = path.normalize(@options.staticRoot)
    @files = []
    @defaultNamespace = 'global'

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

  addFilesBasedOnFilter: (filterPath, namespace) ->
    directoryPath = filterPath.substring(0, filterPath.indexOf('*'))

    searchFiles = filterPath.substring(filterPath.indexOf('*.') + 1)
    searchFiles = undefined if searchFiles == filterPath
    searchNested = filterPath.indexOf('**') > -1


    foundFiles = []
    directoryFind = (dir, retrying=false) ->
      try
        files = fs.readdirSync(dir)

        for file in files
          file = dir + '/' + file
          unless fs.lstatSync(file).isDirectory()
            if searchFiles
              if file.indexOf(searchFiles) > -1
                foundFiles.push file
            else
              foundFiles.push file

          else if searchNested
            directoryFind(file)
      catch err
        if err.code == 'ENOENT'
          unless retrying
            # We need to retry to see if it matches a directory
            # based on a earlier directory in the path. As an
            # example "/path/to/dir* should match /path/to/directory/
            closestDir = dir.split('/')
            dir = closestDir.splice(0, closestDir.length-1).join('/')
            searchFiles = dir + '/' + closestDir.splice(closestDir.length-1).join('')
            searchNested = true
            directoryFind(dir, true)
          else
            # Found no files when retrying either...
            return
        else
          console.log err
    directoryFind(directoryPath)

    foundFiles = foundFiles.sort()
    for file in foundFiles
      @addFile(file, namespace)


  addFile:(file, namespace=@defaultNamespace) =>
    file = path.normalize(file)

    for f in @files
      # File already exists!
      return if file == f.origFile

    # Check if the file is a "filter path"
    if file.indexOf('*') > -1
      return @addFilesBasedOnFilter(file, namespace)

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
      namespace: namespace

  toBundles: =>
    toBundle = (namespace, files) =>
      str = ''
      for file in files
        if file.namespace == namespace
          @_compile(file.origFile, file.file)
          str += fs.readFileSync(file.file, 'utf-8').trim('\n') + '\n'

      str = @minify(str)
      hash = crypto.createHash('md5').update(str).digest('hex')
      filepath = "#{@options.staticRoot}/generated/bundle/#{hash.substring(0, 7)}_#{namespace}#{@fileExtension}"

      writeToFile(filepath, str)

      return filepath

    files = @files
    @files = []

    bundles = []
    for file in files
      bundles.push file.namespace unless file.namespace in bundles

    @addFile(toBundle(bundle, files), bundle) for bundle in bundles

  _compile: (file, writeTo) =>
    compiler.compileFile(@options.compilers, file, (err, content) ->
      throw err if err?
      writeToFile(writeTo, content)
    )
    return writeTo

module.exports = Bundle
