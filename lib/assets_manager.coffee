class AssetsManager
  constructor: (@css, @js)->
    @root = ""

  addCss: (file) =>
    @css.addFile("#{@root}/#{file}", false)

  addJs: (file) =>
    @js.addFile("#{@root}/#{file}", false)

module.exports = AssetsManager
