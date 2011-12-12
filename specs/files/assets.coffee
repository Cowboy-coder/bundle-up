module.exports = (assets) ->
  assets.root = __dirname
  assets.addJs('/coffee/1.coffee')
  assets.addJs('/public/jquery.js')
  assets.addJs('/coffee/2.coffee')
  assets.addJs('/js/1.js')
  assets.addCss('/stylus/main.styl')
  assets.addCss('/public/print.styl')
