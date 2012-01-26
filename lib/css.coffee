csso = require 'csso'
Bundle = require './bundle'
class Css extends Bundle
  constructor: (@options) ->
    @fileExtension = '.css'
    super

  minify: (code) ->
    return code unless @options.minifyCss

    csso.justDoIt(code)

  render: (namespace) ->
    style = ''
    for file in @files
      if file.namespace == namespace
        style += "<link href='#{file.url}' rel='stylesheet' type='text/css'/>"
    return style

  _convertFilename: (filename) ->
    splitted = filename.split('.')
    splitted.splice(0, splitted.length - 1).join('.') + '.css'

module.exports = Css
