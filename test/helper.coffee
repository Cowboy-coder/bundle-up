rimraf = require 'rimraf'
exports.beforeEach = ->
  try
    rimraf.sync(__dirname + '/files/public/generated')
  catch e
    #ignoring...
