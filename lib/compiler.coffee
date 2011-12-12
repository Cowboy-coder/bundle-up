fs = require("fs")
coffee = require("coffee-script")
stylus = require("stylus")

exports.stylusCompile = stylusCompile = (content, file) ->
  return stylus(content)
  .set('filename', file)

exports.compile = compile = (content, file, cb) ->
  fileExt = file.split(".")
  fileExt = fileExt[fileExt.length - 1]

  switch fileExt
    when "coffee"
      return cb(null, coffee.compile(content))
    when "styl"
      stylusCompile(content, file).render (err, css) ->
        console.log err.message if(err)
        return cb(err, css)
    when "css"
      return cb(null, content)
    when "js"
      return cb(null, content)

exports.compileFile =  (file, cb) ->
  content = fs.readFileSync(file, "utf-8")
  return compile(content, file, cb)
