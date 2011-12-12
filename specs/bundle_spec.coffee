suite = require 'jasmine-node'
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
      staticRoot: __dirname + "/../specs/files/public/",
      staticUrlRoot:"/",
      bundle:true

  describe 'individual files', ->
    it 'should create coffee/1.js', ->
      fs.stat __dirname + "/files/public/generated/coffee/1.js", (err, stats) ->
        expect(err).toEqual(null)
        jasmine.asyncSpecDone()
      jasmine.asyncSpecWait()

    it 'should create coffee/2.js', ->
      fs.stat __dirname + "/files/public/generated/coffee/2.js", (err, stats) ->
        expect(err).toEqual(null)
        jasmine.asyncSpecDone()
      jasmine.asyncSpecWait()

    it 'should create js/1.js', ->
      fs.stat __dirname + "/files/public/generated/js/1.js", (err, stats) ->
        expect(err).toEqual(null)
        jasmine.asyncSpecDone()
      jasmine.asyncSpecWait()

    it 'should create stylus/main.css', ->
      fs.stat __dirname + "/files/public/generated/stylus/main.css", (err, stats) ->
        expect(err).toEqual(null)
        jasmine.asyncSpecDone()
      jasmine.asyncSpecWait()

    it 'should create public/print.css', ->
      fs.stat __dirname + "/files/public/generated/print.css", (err, stats) ->
        expect(err).toEqual(null)
        jasmine.asyncSpecDone()
      jasmine.asyncSpecWait()

  describe 'bundled files', ->
    it 'should create a css bundle', ->
      expect(@bundle.css.files.length).toEqual(1)
      fs.stat @bundle.css.files[0].file, (err, stats) ->
        expect(err).toEqual(null)
        jasmine.asyncSpecDone()
      jasmine.asyncSpecWait()

    it 'should create a js bundle', ->
      expect(@bundle.js.files.length).toEqual(1)
      fs.stat @bundle.js.files[0].file, (err, stats) ->
        expect(err).toEqual(null)
        jasmine.asyncSpecDone()
      jasmine.asyncSpecWait()
