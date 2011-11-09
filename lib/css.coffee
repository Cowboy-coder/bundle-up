csso = require "csso"
Bundle = require "./bundle"
class Css extends Bundle
  constructor: (@options) ->
    super

  minify: (code) ->
    return csso.justDoIt(code)

  render: ->
    style = ""
    for file in @files
        style += "<link href='#{file.url}' rel='stylesheet' type='text/css'/>"
    style

  _convertFilename: (filename) ->
    splitted = filename.split(".")
    splitted.splice(0, splitted.length - 1).join(".") + ".css"

module.exports = Css
