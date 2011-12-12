mkdirp = require 'mkdirp'
fs = require 'fs'

#
# Convenient method for writing a file on
# a path that might not exist. This function
# will create all folders provided in the
# path to the file.
#
#
#    writeToFile('/tmp/hi/folder/file.js', "console.log('hi')")
#   
# will create a file at /tmp/hi/folder/file.js with provided content
#
writeToFile = (file, content) ->
  try
    fs.writeFileSync(file, content)
  catch e
    if e.code == 'ENOENT' or e.code == 'EBADF'
      splitted = file.split('/')
      mkdirp.sync(splitted.splice(0, splitted.length-1).join('/'), 0777)

      # Retry!
      writeToFile(file, content)
    else
      console.log e

# 
# This is fancy
#
normalizeUrl = (url) ->
  return url.replace('//', '/')

exports.writeToFile = writeToFile
exports.normalizeUrl = normalizeUrl
