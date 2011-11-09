fs = require("fs")
coffee = require("coffee-script")
stylus = require("stylus")

stylusCompile = (content, file) ->
  stylus(content)
  .set('filename', file)

exports.compileFile =  (file, cb) ->
  content = fs.readFileSync(file, "utf-8")

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
