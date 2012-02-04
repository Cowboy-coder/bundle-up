expect = require 'expect.js'
Js = require './../lib/js'
Css = require './../lib/css'
helper = require './helper'
fs = require 'fs'

describe 'When adding files', ->
  beforeEach ->
    helper.beforeEach()
    @js = new Js(staticRoot:"#{__dirname}/files/public", staticUrlRoot:'/')
    @css = new Css(staticRoot:"#{__dirname}/files/public", staticUrlRoot:'/')

  it 'should add the correct paths when adding a js file', ->
    @js.addFile(__dirname + '/files/js/1.js')
    expect(@js.files.length).to.equal(1)
    file = @js.files[0]

    expect(file.file).to.equal("#{__dirname}/files/public/generated/js/1.js")
    expect(file.origFile).to.equal(__dirname + '/files/js/1.js')
    expect(file.url).to.equal('/generated/js/1.js')

  it 'should add the correct paths when adding a coffee file', ->
    @js.addFile(__dirname + '/files/coffee/1.coffee')
    expect(@js.files.length).to.equal(1)
    file = @js.files[0]

    expect(file.file).to.equal("#{__dirname}/files/public/generated/coffee/1.js")
    expect(file.origFile).to.equal(__dirname + '/files/coffee/1.coffee')
    expect(file.url).to.equal('/generated/coffee/1.js')

  it 'should add the correct paths when adding a css file', ->
    @css.addFile(__dirname + '/files/css/screen.css')
    expect(@css.files.length).to.equal(1)
    file = @css.files[0]

    expect(file.file).to.equal("#{__dirname}/files/public/generated/css/screen.css")
    expect(file.origFile).to.equal(__dirname + '/files/css/screen.css')
    expect(file.url).to.equal('/generated/css/screen.css')

  it 'should add the correct paths when adding a styl file', ->
    @css.addFile(__dirname + '/files/stylus/main.styl')
    expect(@css.files.length).to.equal(1)
    file = @css.files[0]

    expect(file.file).to.equal("#{__dirname}/files/public/generated/stylus/main.css")
    expect(file.origFile).to.equal(__dirname + '/files/stylus/main.styl')
    expect(file.url).to.equal('/generated/stylus/main.css')

  it 'should not point to generated/ when adding a js file already in staticRoot', ->
    @js.addFile(__dirname + '/files/public/jquery.js')
    expect(@js.files.length).to.equal(1)
    file = @js.files[0]

    expect(file.file).to.equal("#{__dirname}/files/public/jquery.js")
    expect(file.origFile).to.equal("#{__dirname}/files/public/jquery.js")
    expect(file.url).to.equal('/jquery.js')

  it 'should not point to generated/ when adding a css file already in staticRoot', ->
    @css.addFile(__dirname + '/files/public/styles/bootstrap.css')
    expect(@css.files.length).to.equal(1)
    file = @css.files[0]

    expect(file.file).to.equal("#{__dirname}/files/public/styles/bootstrap.css")
    expect(file.origFile).to.equal("#{__dirname}/files/public/styles/bootstrap.css")
    expect(file.url).to.equal('/styles/bootstrap.css')

  it 'should add the correct paths when adding a coffee file inside staticRoot', ->
    @js.addFile(__dirname + '/files/public/main.coffee')
    expect(@js.files.length).to.equal(1)
    file = @js.files[0]

    expect(file.file).to.equal("#{__dirname}/files/public/generated/main.js")
    expect(file.origFile).to.equal(__dirname + '/files/public/main.coffee')
    expect(file.url).to.equal('/generated/main.js')

  it 'should add the correct paths when adding a styl file inside staticRoot', ->
    @css.addFile(__dirname + '/files/public/print.styl')
    expect(@css.files.length).to.equal(1)
    file = @css.files[0]

    expect(file.file).to.equal("#{__dirname}/files/public/generated/print.css")
    expect(file.origFile).to.equal(__dirname + '/files/public/print.styl')
    expect(file.url).to.equal('/generated/print.css')

  it 'should not change the css file when adding a file already in staticRoot', ->
    file = __dirname + '/files/public/styles/bootstrap.css'
    beforeStat = fs.statSync(file)
    @css.addFile(file)
    afterStat = fs.statSync(file)
    works = false
    for key of beforeStat
      works = true
      expect(beforeStat[key]).to.eql(afterStat[key])
    expect(works).to.equal(true)

  it 'should not change the js file when adding a file already in staticRoot', ->
    file = __dirname + '/files/public/jquery.js'
    beforeStat = fs.statSync(file)
    @css.addFile(file)
    afterStat = fs.statSync(file)
    works = false
    for key of beforeStat
      works = true
      expect(beforeStat[key]).to.eql(afterStat[key])
    expect(works).to.equal(true)

  it 'should only add the file once when adding the same file twice', ->
    @js.addFile(__dirname + '/files/coffee/1.coffee')
    @js.addFile(__dirname + '/files/coffee/1.coffee')

    expect(@js.files.length).to.equal(1)
    file = @js.files[0]
    expect(file.file).to.equal("#{__dirname}/files/public/generated/coffee/1.js")
    expect(file.origFile).to.equal(__dirname + '/files/coffee/1.coffee')
    expect(file.url).to.equal('/generated/coffee/1.js')

  describe 'filtered paths', ->
    it 'should be able to add 1.coffee using files/nested/js/*.coffee', ->
      @js.addFile(__dirname + '/files/nested/js/*.coffee')
      expect(@js.files.length).to.equal(1)
      expect(@js.files[0].origFile).to.equal(__dirname + '/files/nested/js/1.coffee')

    it 'should be able to add all 2 coffee files using files/nested/js/**.coffee', ->
      @js.addFile(__dirname + '/files/nested/js/**.coffee')
      expect(@js.files.length).to.equal(2)
      expect(@js.files[0].origFile).to.equal(__dirname + '/files/nested/js/1.coffee')
      expect(@js.files[1].origFile).to.equal(__dirname + '/files/nested/js/sub/2.coffee')

    it 'should be able to add all 6 files using files/coffee/js/**', ->
      @js.addFile(__dirname + '/files/nested/js/**')
      expect(@js.files.length).to.equal(6)
      expect(@js.files[0].origFile).to.equal(__dirname + '/files/nested/js/1.coffee')
      expect(@js.files[1].origFile).to.equal(__dirname + '/files/nested/js/1.js')
      expect(@js.files[2].origFile).to.equal(__dirname + '/files/nested/js/sub/2.coffee')
      expect(@js.files[3].origFile).to.equal(__dirname + '/files/nested/js/sub/2.js')
      expect(@js.files[4].origFile).to.equal(__dirname + '/files/nested/js/sub/sub2/3.js')
      expect(@js.files[5].origFile).to.equal(__dirname + '/files/nested/js/sub/sub2/4.js')

    it 'should add 0 files when trying /files/invalid*', ->
      @js.addFile(__dirname + '/files/invalid*')
      expect(@js.files.length).to.equal(0)

    it 'should add 6 files when trying /files/nested/j*', ->
      @js.addFile(__dirname + '/files/nested/j*')
      expect(@js.files.length).to.equal(6)
