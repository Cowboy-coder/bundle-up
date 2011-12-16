class AssetsManager
  constructor: (@css, @js)->
    @root = ''

  addCss: (file, namespace=undefined) =>
    @css.addFile("#{@root}/#{file}", namespace)

  addJs: (file, namespace=undefined) =>
    @js.addFile("#{@root}/#{file}", namespace)

module.exports = AssetsManager
