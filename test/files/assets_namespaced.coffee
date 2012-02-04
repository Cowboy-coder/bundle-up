module.exports = (assets) ->
  assets.root = __dirname
  assets.addJs('/coffee/1.coffee')
  assets.addJs('/coffee/2.coffee', 'custom_namespace')
  assets.addJs('/coffee/3.coffee', 'custom_namespace')
  assets.addCss('/stylus/main.styl')
  assets.addCss('/public/print.styl', 'print_namespace')
