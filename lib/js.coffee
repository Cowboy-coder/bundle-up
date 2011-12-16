Bundle = require './bundle'
class Js extends Bundle
  constructor: (@options) ->
    @fileExtension = '.js'
    super

  minify: (code) ->
    # Haven't found any nice minifier
    # that doesn't break the code
    return code

  render: (namespace) ->
    js = ''
    for file in @files
      if file.namespace == namespace
        js += "<script src='#{file.url}' type='text/javascript'></script>"
    return js

  _convertFilename: (filename) ->
    splitted = filename.split('.')
    splitted.splice(0, splitted.length - 1).join('.') + '.js'

module.exports = Js
