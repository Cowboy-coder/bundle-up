coffee = require 'coffee-script'
stylus = require 'stylus'

module.exports =
  stylus: (content, file) ->
    return stylus(content)
    .set('filename', file)
  coffee: (content, file) ->
    return coffee.compile(content)
  js: (content) ->
    return content
  css: (content) ->
    return content
