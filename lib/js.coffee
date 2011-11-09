Bundle = require "./bundle"
class Js extends Bundle
  constructor: (@options) ->
    super

  minify: (code) ->
    # Haven't found any nice minifier
    # that doesn't break the code
    return code

  render: () ->
    js = ""
    for file in @files
        js += "<script src='#{file.url}' type='text/javascript'></script>"
    js

  _convertFilename: (filename) ->
    splitted = filename.split(".")
    splitted.splice(0, splitted.length - 1).join(".") + ".js"

module.exports = Js
