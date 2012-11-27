Bundle = require './bundle'
UglifyJS = require 'uglify-js'
class Js extends Bundle
  constructor: (@options) ->
    @fileExtension = '.js'
    super

  minify: (code) ->
    return code unless @options.minifyJs
    UglifyJS.minify(code, { fromString: true }).code # Minify with UglifyJS (v2)

  render: (namespace) ->
    js = ''
    for file in @files
      if file.namespace == namespace
        js += "<script src='#{file.url}' type='text/javascript'></script>"
    js

  _convertFilename: (filename) ->
    splitted = filename.split('.')
    splitted.splice(0, splitted.length - 1).join('.') + '.js'

module.exports = Js
