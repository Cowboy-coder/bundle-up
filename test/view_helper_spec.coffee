expect = require 'expect.js'
BundleUp = require './../index'
Js = require './../lib/js'
Css = require './../lib/css'
helper = require './helper'
fs = require 'fs'
express = require 'express'
request = require 'request'

describe 'View Helper', ->
  beforeEach ->
    @app = express.createServer()
    @app.set('views', __dirname + '/views')
    @bundle = BundleUp @app, __dirname + '/files/assets_namespaced.coffee',
      staticRoot: __dirname + '/files/public/',
      staticUrlRoot:'/',
      bundle:true

    @app.get '/globalJs', (req, res) ->
      res.render 'globalJs.jade', layout:false

    @app.get '/globalJs/custom_namespaceJs', (req, res) ->
      res.render 'globalAndCustomJs.jade', layout:false

    @app.get '/custom_namespaceJs', (req, res) ->
      res.render 'customJs.jade', layout:false

    @app.get '/globalCss', (req, res) ->
      res.render 'globalCss.jade', layout:false

    @app.get '/globalJs/printNamespaceCss', (req, res) ->
      res.render 'globalAndPrintCss.jade', layout:false

    @app.get '/print_namespaceCss', (req, res) ->
      res.render 'printCss.jade', layout:false

    @app.listen(1338)

  afterEach ->
    @app.close()

  describe 'renderJs', ->
    it 'should render the global.js bundle', (done) ->
      request.get 'http://localhost:1338/globalJs', (err, res) =>
        expect(@bundle.js.files[0].namespace).to.equal('global')
        expect(res.body).to.contain(@bundle.js.files[0].url)

        expect(res.body).to.not.contain(@bundle.js.files[1].url)
        done()

    it 'should render the global.js and the custom_namespace.js bundle', (done) ->
      request.get 'http://localhost:1338/globalJs/custom_namespaceJs', (err, res) =>
        expect(@bundle.js.files[0].namespace).to.equal('global')
        expect(@bundle.js.files[1].namespace).to.equal('custom_namespace')
        expect(res.body).to.contain(@bundle.js.files[0].url)
        expect(res.body).to.contain(@bundle.js.files[1].url)
        done()

    it 'should only render the custom_namespace.js bundle', (done) ->
      request.get 'http://localhost:1338/custom_namespaceJs', (err, res) =>
        expect(@bundle.js.files[1].namespace).to.equal('custom_namespace')
        expect(res.body).to.contain(@bundle.js.files[1].url)

        expect(res.body).to.not.contain(@bundle.js.files[0].url)
        done()

  describe 'renderStyles', ->
    it 'should render the global.css bundle', (done) ->
      request.get 'http://localhost:1338/globalCss', (err, res) =>
        expect(@bundle.js.files[0].namespace).to.equal('global')
        expect(res.body).to.contain(@bundle.js.files[0].url)

        expect(res.body).to.not.contain(@bundle.js.files[1].url)
        done()

    it 'should render the global.css and the print_namespace.css bundle', (done) ->
      request.get 'http://localhost:1338/globalJs/printNamespaceCss', (err, res) =>
        expect(@bundle.css.files[0].namespace).to.equal('global')
        expect(@bundle.css.files[1].namespace).to.equal('print_namespace')
        expect(res.body).to.contain(@bundle.css.files[0].url)
        expect(res.body).to.contain(@bundle.css.files[1].url)
        done()

    it 'should only render the print_namespace.css bundle', (done) ->
      request.get 'http://localhost:1338/print_namespaceCss', (err, res) =>
        expect(@bundle.css.files[1].namespace).to.equal('print_namespace')
        expect(res.body).to.contain(@bundle.css.files[1].url)

        expect(res.body).to.not.contain(@bundle.css.files[0].url)
        done()
