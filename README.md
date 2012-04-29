Bundle up!  [![Build Status](https://secure.travis-ci.org/Cowboy-coder/bundle-up.png)](https://secure.travis-ci.org/Cowboy-coder/bundle-up)
==========

Bundle up is a middleware for connect to manage all client-side assets in an organized way.

Installation
------------

    $ npm install bundle-up

Usage
-----

``` js
var BundleUp = require('bundle-up');

BundleUp(app, __dirname + '/assets', {
  staticRoot: __dirname + '/public/',
  staticUrlRoot:'/',
  bundle:true,
  minifyCss: true,
  minifyJs: true
});

// To actually serve the files a static file
// server needs to be added after Bundle Up
app.use(express.static(__dirname + '/public/'))
```

The first parameter to the BundleUp middleware is the app object and the second is the path to the assets file. Through the assets file all client-side assets needs to get added.

``` js
// assets.js
module.exports = function(assets) {
  assets.root = __dirname;
  assets.addJs('/public/js/jquery-1.6.4.min.js');
  assets.addJs('/public/js/jquery.placeholder.min.js');
  assets.addJs('/app/client/main.coffee');

  assets.addCss('/public/bootstrap/bootstrap.min.css');
  assets.addCss('/app/styles/screen.styl');
}
```

Just point to a file (.js, .css, .coffee or .styl are currently supported) anywhere in your app directory. In your view you can then just render all the css or javascript files by calling `renderStyles` and `renderJs` like this:

``` jade
!!!
html
  head
    != renderStyles()
  body!= body
    != renderJs()
```

By default this will render

``` html
<link href='/bootstrap/bootstrap.min.css' media='screen' rel='stylesheet' type='text/css'/>
<link href='/generated/app/styles/screen.css' media='screen' rel='stylesheet' type='text/css'/>

<script src='/js/jquery-1.6.4.min.js' type='text/javascript'></script>
<script src='/js/jquery.placeholder.min.js' type='text/javascript'></script>
<script src='/generated/app/client/main.js' type='text/javascript'></script>
```

All assets will be compiled on-the-fly when `bundle:false` is set. Therefore the server never
needs to be restarted when editing the different assets.

To render bundles `bundle:true` needs to be passed as a parameter to the middleware. This will concatenate all javascript and css files into bundles and render this:

``` html
<link href='/generated/bundle/d7aa56c_global.css' media='screen' rel='stylesheet' type='text/css'/>
<script src='/generated/bundle/1e4b515_global.js' type='text/javascript'></script>
```

All bundles are generated during startup. The filename will change with the content so you should configure your web server with far future expiry headers.

### generated/

All files that needs to be compiled, copied (if you are bundling up a file that doesn't reside in your `public/` directory) or bundled will end up in `public/generated/` directory. This is to have an organized way to separate whats actually *your code* and whats *generated code*.

### Filtered paths

All files can be added in a directory by using a "filtered path" like this

``` js
// assets.js
module.exports = function(assets) {
  assets.addJs(__dirname + '/public/js/**'); //adds all files in /public/js (subdirectories included)
  assets.addJs(__dirname + '/public/*.js'); //adds all js files in /public
  assets.addJs(__dirname + '/cs/**.coffee'); //adds all coffee files in /cs (subdirectories included)
});
```
### Namespaces

Sometimes all javascript or css files cannot be bundled into the same bundle. In that case
namespaces can be used

``` js
// assets.js
module.exports = function(assets) {
  assets.addJs(__dirname + '/public/js/1.js');
  assets.addJs(__dirname + '/public/js/2.js');
  assets.addJs(__dirname + '/public/locales/en_US.js', 'en_US');

  assets.addJs(__dirname + '/public/css/1.css');
  assets.addJs(__dirname + '/public/css/2.css');
  assets.addJs(__dirname + '/public/css/ie.css', 'ie');
});
```

``` jade
!!!
html
  head
    != renderStyles()
    != renderStyles('ie')
  body!= body
    != renderJs()
    != renderJs('en_US')
```

which will render this with `bundle:false`:

``` html
<link href='/css/1.css' media='screen' rel='stylesheet' type='text/css'/>
<link href='/css/2.css' media='screen' rel='stylesheet' type='text/css'/>
<link href='/css/ie.css' media='screen' rel='stylesheet' type='text/css'/>

<script src='/js/1.js' type='text/javascript'></script>
<script src='/js/2.js' type='text/javascript'></script>
<script src='/locales/en_US.js' type='text/javascript'></script>
```

and this with `bundle:true`:

``` html
<link href='/generated/bundle/d7aa56c_global.css' media='screen' rel='stylesheet' type='text/css'/>
<link href='/generated/bundle/d7aa56c_ie.css' media='screen' rel='stylesheet' type='text/css'/>
<script src='/generated/bundle/1e4b515_global.js' type='text/javascript'></script>
<script src='/generated/bundle/1e4b515_en_US.js' type='text/javascript'></script>
```

License
-------

MIT licensed
