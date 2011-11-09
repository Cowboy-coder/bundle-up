AssetsManager = require "./assets_manager"
Js = require "./js"
Css = require "./css"

class BundleUp
  constructor: (path, options = {bundle:false}) ->
    @js = new Js(options)
    @css = new Css(options)

    require(path)(new AssetsManager(@css, @js))

    if options.bundle
      filename = @js.toFile("global.js")
      @js.files = []
      @js.addFile(filename, true)

      filename = @css.toFile("global.css")
      @css.files = []
      @css.addFile(filename, true)

    return @middleware
    
  middleware: (req, res, next) =>
    res.local("renderStyles", @css.render())
    res.local("renderJs", @js.render())
    next()

module.exports = BundleUp
