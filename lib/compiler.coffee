fs = require 'fs'

exports.compile = compile = (compilers, content, file, cb) ->
  fileExt = file.split('.')
  fileExt = fileExt[fileExt.length - 1]

  switch fileExt
    when 'coffee'
      return cb(null, compilers.coffee(content))
    when 'styl'
      compilers.stylus(content, file).render (err, css) ->
        console.log err.message if(err)
        return cb(err, css)
    when 'css'
      return cb(null, compilers.css(content))
    when 'js'
      return cb(null, compilers.js(content))

exports.compileFile =  (compilers, file, cb) ->
  content = fs.readFileSync(file, 'utf-8')
  return compile(compilers, content, file, cb)
