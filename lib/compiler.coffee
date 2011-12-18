fs = require 'fs'

exports.compile = compile = (compilers, content, file, cb) ->
  fileExt = file.split('.')
  fileExt = fileExt[fileExt.length - 1]

  switch fileExt
    when 'coffee'
      try
        return cb(null, compilers.coffee(content, file))
      catch err
        console.log file + ':\n  ' + err.message + "\n"
        return cb(err, err.message)
    when 'styl'
      compilers.stylus(content, file).render (err, css) ->
        if err?
          console.log err.message
          css = err.message
        return cb(err, css)
    when 'css'
      return cb(null, compilers.css(content))
    when 'js'
      return cb(null, compilers.js(content))

exports.compileFile =  (compilers, file, cb) ->
  content = fs.readFileSync(file, 'utf-8')
  return compile(compilers, content, file, cb)
