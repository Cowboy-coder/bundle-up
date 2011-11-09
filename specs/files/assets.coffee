module.exports (assets) ->
	assets.root = __dirname + "/file"
	assets.addJs("/app/client/main.coffee");
	assets.addJs("/public/js/jquery-1.6.4.min.js");
	assets.addJs("/public/js/jquery.placeholder.min.js");
	assets.addJs("/public/js/templates.js");
	assets.addJs("/public/javascripts/soft.js");
	assets.addJs("/public/javascripts/soft2.js");

	assets.addCss("/app/styles/screen.styl");
}

