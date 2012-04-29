coffee = require 'coffee-script'
stylus = require 'stylus'
less   = require 'less'

module.exports =
  stylus: (content, file) ->
    return stylus(content)
    .set('filename', file)
  less: (content, file) ->
    return new (less.Parser)(
      paths : [require('path').dirname(file) + '/']
      filename : require('path').basename(file)
    )
  coffee: (content, file) ->
    return coffee.compile(content)
  js: (content) ->
    return content
  css: (content) ->
    return content
