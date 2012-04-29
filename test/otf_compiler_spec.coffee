expect = require 'expect.js'
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
    bundle = BundleUp @app, __dirname + '/files/assets.coffee',
      staticRoot: __dirname + '/files/public/',
      staticUrlRoot:"/",
      bundle:false
    @app.use(express.static(__dirname + '/files/public/'))
    
    @app.listen(1338)

  afterEach ->
    @app.close()

  it 'should compile stylus files correctly', (done) ->
    request.get 'http://localhost:1338/generated/stylus/main.css', (err, res) ->
      expected = """
      h1 {
        color: #00f;
      }
      body {
        background-color: #ff0;
      }

      """
      expect(res.body).to.equal(expected)
      done()

  it 'should compile coffee files correctly', (done) ->
    request.get 'http://localhost:1338/generated/coffee/1.js', (err, res) ->
      expected = '''
      (function() {

        console.log('1');

      }).call(this);

      '''
      expect(res.body).to.equal(expected)
      done()

  it 'should map imported files for main.styl first time it is requested', (done) ->
    file = bundle.css.files[0]
    expect(file.origFile).to.equal(__dirname + '/files/stylus/main.styl')
    expect(file._imports).to.equal(undefined)
    request.get 'http://localhost:1338/generated/stylus/main.css', (err, res) ->
      expect(file._imports).to.not.equal(undefined)
      found = false
      for imp in file._imports
        if imp.file == __dirname + '/files/stylus/typography.styl'
          found = true
      expect(found).to.equal(true)

      done()

  it 'should re-compile main.styl when imported file change', (done) ->
    file = bundle.css.files[0]
    expect(file.origFile).to.equal(__dirname + '/files/stylus/main.styl')
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
        expect(beforeTime).to.not.equal(afterTime)
        importedFile = file._imports[1]
        expect(importedFile.file).to.equal(__dirname + '/files/stylus/typography.styl')
        expect(importedFile.mtime).to.eql(afterTime)

        # Clean up
        fs.writeFileSync __dirname + '/files/stylus/typography.styl', oldContent, 'utf8'
        done()

  describe 'Error handling', ->
    it 'should respond with 500 when requesting a coffee file with syntax errors', (done) ->
      bundle.js.addFile(__dirname + '/files/coffee/syntax_error.coffee')
      request.get 'http://localhost:1338/generated/coffee/syntax_error.js', (err, res) ->
        expect(res.statusCode).to.equal(500)

        done()

    it 'should respond with 500 when requesting a stylus file with syntax errors', (done) ->
      bundle.css.addFile(__dirname + '/files/stylus/syntax_error.styl')
      request.get 'http://localhost:1338/generated/stylus/syntax_error.css', (err, res) ->
        expect(res.statusCode).to.equal(500)

        done()

    it 'should respond with 500 when requesting a file not found', (done) ->
      bundle.js.addFile(__dirname + '/files/coffee/not_found.coffee')
      request.get 'http://localhost:1338/generated/coffee/not_found.js', (err, res) ->
        expect(res.statusCode).to.equal(500)

        done()
