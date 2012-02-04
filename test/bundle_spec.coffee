expect = require 'expect.js'
BundleUp = require './../index'
Js = require './../lib/js'
Css = require './../lib/css'
helper = require './helper'
fs = require 'fs'
express = require 'express'

describe 'bundle:true', ->
  beforeEach ->
    helper.beforeEach()
    @app = express.createServer()
    @bundle = BundleUp @app, __dirname + "/files/assets.coffee",
      staticRoot: __dirname + "/files/public/",
      staticUrlRoot:"/",
      bundle:true

  describe 'individual files', ->
    it 'should create coffee/1.js', (done) ->
      fs.stat __dirname + "/files/public/generated/coffee/1.js", (err, stats) ->
        expect(err).to.equal(null)
        done()

    it 'should create coffee/2.js', (done) ->
      fs.stat __dirname + "/files/public/generated/coffee/2.js", (err, stats) ->
        expect(err).to.equal(null)
        done()

    it 'should create js/1.js', (done) ->
      fs.stat __dirname + "/files/public/generated/js/1.js", (err, stats) ->
        expect(err).to.equal(null)
        done()

    it 'should create stylus/main.css', (done) ->
      fs.stat __dirname + "/files/public/generated/stylus/main.css", (err, stats) ->
        expect(err).to.equal(null)
        done()

    it 'should create public/print.css', (done) ->
      fs.stat __dirname + "/files/public/generated/print.css", (err, stats) ->
        expect(err).to.equal(null)
        done()

  describe 'bundled files', ->
    it 'should create a css bundle', (done) ->
      expect(@bundle.css.files.length).to.equal(1)
      fs.stat @bundle.css.files[0].file, (err, stats) ->
        expect(err).to.equal(null)
        done()

    it 'should create a js bundle', (done) ->
      expect(@bundle.js.files.length).to.equal(1)
      fs.stat @bundle.js.files[0].file, (err, stats) ->
        expect(err).to.equal(null)
        done()
