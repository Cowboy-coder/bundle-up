suite = require 'jasmine-node'
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
    expect(@js.files.length).toEqual(1)
    file = @js.files[0]

    expect(file.file).toEqual("#{__dirname}/files/public/generated/js/1.js")
    expect(file.origFile).toEqual(__dirname + '/files/js/1.js')
    expect(file.url).toEqual('/generated/js/1.js')

  it 'should add the correct paths when adding a coffee file', ->
    @js.addFile(__dirname + '/files/coffee/1.coffee')
    expect(@js.files.length).toEqual(1)
    file = @js.files[0]

    expect(file.file).toEqual("#{__dirname}/files/public/generated/coffee/1.js")
    expect(file.origFile).toEqual(__dirname + '/files/coffee/1.coffee')
    expect(file.url).toEqual('/generated/coffee/1.js')

  it 'should add the correct paths when adding a css file', ->
    @css.addFile(__dirname + '/files/css/screen.css')
    expect(@css.files.length).toEqual(1)
    file = @css.files[0]

    expect(file.file).toEqual("#{__dirname}/files/public/generated/css/screen.css")
    expect(file.origFile).toEqual(__dirname + '/files/css/screen.css')
    expect(file.url).toEqual('/generated/css/screen.css')

  it 'should add the correct paths when adding a styl file', ->
    @css.addFile(__dirname + '/files/stylus/main.styl')
    expect(@css.files.length).toEqual(1)
    file = @css.files[0]

    expect(file.file).toEqual("#{__dirname}/files/public/generated/stylus/main.css")
    expect(file.origFile).toEqual(__dirname + '/files/stylus/main.styl')
    expect(file.url).toEqual('/generated/stylus/main.css')

  it 'should not point to generated/ when adding a js file already in staticRoot', ->
    @js.addFile(__dirname + '/files/public/jquery.js')
    expect(@js.files.length).toEqual(1)
    file = @js.files[0]

    expect(file.file).toEqual("#{__dirname}/files/public/jquery.js")
    expect(file.origFile).toEqual("#{__dirname}/files/public/jquery.js")
    expect(file.url).toEqual('/jquery.js')

  it 'should not point to generated/ when adding a css file already in staticRoot', ->
    @css.addFile(__dirname + '/files/public/styles/bootstrap.css')
    expect(@css.files.length).toEqual(1)
    file = @css.files[0]

    expect(file.file).toEqual("#{__dirname}/files/public/styles/bootstrap.css")
    expect(file.origFile).toEqual("#{__dirname}/files/public/styles/bootstrap.css")
    expect(file.url).toEqual('/styles/bootstrap.css')

  it 'should add the correct paths when adding a coffee file inside staticRoot', ->
    @js.addFile(__dirname + '/files/public/main.coffee')
    expect(@js.files.length).toEqual(1)
    file = @js.files[0]

    expect(file.file).toEqual("#{__dirname}/files/public/generated/main.js")
    expect(file.origFile).toEqual(__dirname + '/files/public/main.coffee')
    expect(file.url).toEqual('/generated/main.js')

  it 'should add the correct paths when adding a styl file inside staticRoot', ->
    @css.addFile(__dirname + '/files/public/print.styl')
    expect(@css.files.length).toEqual(1)
    file = @css.files[0]

    expect(file.file).toEqual("#{__dirname}/files/public/generated/print.css")
    expect(file.origFile).toEqual(__dirname + '/files/public/print.styl')
    expect(file.url).toEqual('/generated/print.css')

  it 'should not change the css file when adding a file already in staticRoot', ->
    file = __dirname + '/files/public/styles/bootstrap.css'
    beforeStat = fs.statSync(file)
    @css.addFile(file)
    afterStat = fs.statSync(file)
    works = false
    for key of beforeStat
      works = true
      expect(beforeStat[key]).toEqual(afterStat[key])
    expect(works).toBeTruthy()

  it 'should not change the js file when adding a file already in staticRoot', ->
    file = __dirname + '/files/public/jquery.js'
    beforeStat = fs.statSync(file)
    @css.addFile(file)
    afterStat = fs.statSync(file)
    works = false
    for key of beforeStat
      works = true
      expect(beforeStat[key]).toEqual(afterStat[key])
    expect(works).toBeTruthy()
