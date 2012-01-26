Bundle = require './bundle'
UglifyJS = require 'uglify-js'
class Js extends Bundle
  constructor: (@options) ->
    @fileExtension = '.js'
    super

  minify: (code) ->
    return code unless @options.minifyJs

    ast = UglifyJS.parser.parse code # parse code and get the initial AST
    ast = UglifyJS.uglify.ast_mangle ast # get a new AST with mangled names
    ast = UglifyJS.uglify.ast_squeeze ast # get an AST with compression optimizations
    UglifyJS.uglify.gen_code ast # compressed code here

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
