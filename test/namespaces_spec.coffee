expect = require 'expect.js'
BundleUp = require './../index'
Js = require './../lib/js'
Css = require './../lib/css'
helper = require './helper'
fs = require 'fs'
express = require 'express'

describe 'Namespaces', ->
  beforeEach ->
    helper.beforeEach()
    @js = new Js(staticRoot:"#{__dirname}/files/public", staticUrlRoot:'/')

  it 'should have default namespace set to "global"', ->
    @js.addFile(__dirname + '/files/coffee/1.coffee')
    expect(@js.files[0].namespace).to.equal('global')

  it 'should add the correct namespaces when 3 coffee files in separate namespaces', ->
    @js.addFile(__dirname + '/files/coffee/1.coffee', 'namespace1')
    @js.addFile(__dirname + '/files/coffee/2.coffee', 'namespace2')
    @js.addFile(__dirname + '/files/coffee/3.coffee', 'namespace3')

    expect(@js.files.length).to.equal(3)
    expect(@js.files[0].namespace).to.equal('namespace1')
    expect(@js.files[1].namespace).to.equal('namespace2')
    expect(@js.files[2].namespace).to.equal('namespace3')

  it 'should add the correct namespaces when using filtered paths', ->
    @js.addFile(__dirname + '/files/coffee/*.coffee', 'namespace1')

    expect(@js.files.length).to.equal(4)
    expect(@js.files[0].namespace).to.equal('namespace1')
    expect(@js.files[1].namespace).to.equal('namespace1')
    expect(@js.files[2].namespace).to.equal('namespace1')
    expect(@js.files[3].namespace).to.equal('namespace1')

  describe 'bundle:true', ->
    beforeEach ->
      @app = express.createServer()
      @bundle = BundleUp @app, __dirname + '/files/assets_namespaced.coffee',
        staticRoot: __dirname + '/files/public/',
        staticUrlRoot:'/',
        bundle:true

    it 'should create 2 js bundles and 2 css bundles', ->
      expect(@bundle.js.files.length).to.equal(2)
      expect(@bundle.css.files.length).to.equal(2)

    it 'should create global.js bundle and custom_namespace.bundle.js', ->
      expect(@bundle.js.files.length).to.equal(2)
      expect(@bundle.js.files[0].origFile).to.contain('global.js')
      expect(@bundle.js.files[1].origFile).to.contain('custom_namespace.js')

      expect(@bundle.js.files[0].namespace).to.equal('global')
      expect(@bundle.js.files[1].namespace).to.equal('custom_namespace')
