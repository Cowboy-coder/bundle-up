suite = require 'jasmine-node'
BundleUp = require './../index'
Js = require './../lib/js'
Css = require './../lib/css'
helper = require './helper'
fs = require 'fs'
express = require 'express'
request = require 'request'

describe 'OnTheFlyCompiler', ->
  bundle = {}
  beforeEach ->
    helper.beforeEach()
    @app = express.createServer()
    @bundle = BundleUp @app, __dirname + '/files/assets.coffee',
      staticRoot: __dirname + '/../specs/files/public/',
      staticUrlRoot:"/",
      bundle:false
    bundle = @bundle
    @app.use(express.static( __dirname + '/../specs/files/public/'))
    
    @app.listen(1338)

  afterEach ->
    @app.close()

  it 'should compile stylus files correctly', ->
    request.get 'http://localhost:1338/generated/stylus/main.css', (err, res) ->
      expected = """
      h1 {
        color: #00f;
      }
      body {
        background-color: #ff0;
      }

      """
      expect(res.body).toEqual(expected)
      jasmine.asyncSpecDone()
    jasmine.asyncSpecWait()

  it 'should compile coffee files correctly', ->
    request.get 'http://localhost:1338/generated/coffee/1.js', (err, res) ->
      expected = "\n  console.log('1');\n"
      expect(res.body).toEqual(expected)
      jasmine.asyncSpecDone()
    jasmine.asyncSpecWait()

  it 'should map imported files for main.styl first time it is requested', =>
    file = bundle.css.files[0]
    expect(file.origFile).toEqual(__dirname + '/files/stylus/main.styl')
    expect(file._imports).toBeUndefined()
    request.get 'http://localhost:1338/generated/stylus/main.css', (err, res) ->
      expect(file._imports).toBeDefined()
      found = false
      for imp in file._imports
        if imp.file == __dirname + '/files/stylus/typography.styl'
          found = true
      expect(found).toBeTruthy()

      jasmine.asyncSpecDone()
    jasmine.asyncSpecWait()

  it 'should re-compile main.styl when imported file change', ->
    file = bundle.css.files[0]
    expect(file.origFile).toEqual(__dirname + '/files/stylus/main.styl')
    request.get 'http://localhost:1338/generated/stylus/main.css', (err, res) ->
      beforeTime = (fs.statSync __dirname + '/files/stylus/typography.styl').mtime

      oldContent = fs.readFileSync __dirname + '/files/stylus/typography.styl', 'utf8'
      fs.writeFileSync __dirname + '/files/stylus/typography.styl', oldContent + '\n', 'utf8'

      afterTime = (fs.statSync __dirname + '/files/stylus/typography.styl').mtime

      request.get 'http://localhost:1338/generated/stylus/main.css', (err, res) ->
        # Apparently the main.css file mtime doesn't change
        # most likely because the content in the file is the same...
        # therefore we make the expectations on the typography file
        # instead
        expect(beforeTime).toNotEqual(afterTime)
        importedFile = file._imports[1]
        expect(importedFile.file).toEqual(__dirname + '/files/stylus/typography.styl')
        expect(importedFile.mtime).toEqual(afterTime)

        # Clean up
        fs.writeFileSync __dirname + '/files/stylus/typography.styl', oldContent, 'utf8'
        jasmine.asyncSpecDone()
    jasmine.asyncSpecWait()
