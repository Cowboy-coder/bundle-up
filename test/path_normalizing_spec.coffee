expect = require 'expect.js'
Js = require './../lib/js'
Css = require './../lib/css'
helper = require './helper'
fs = require 'fs'

describe 'Path normalizing', ->
  beforeEach ->
    helper.beforeEach()

  describe 'staticRoot', ->
    it "shouldn't matter if staticRoot ends with / or not", ->
      @js = new Js(staticRoot:"#{__dirname}/files/public", staticUrlRoot:'/')
      @js.addFile(__dirname + '/files/js/1.js')
      firstFile = @js.files[0]
      @js = new Js(staticRoot:"#{__dirname}/files/public/", staticUrlRoot:'/')
      @js.addFile(__dirname + '/files/js/1.js')
      secondFile = @js.files[0]
      expect(firstFile.file).to.equal(secondFile.file)
      expect(firstFile.origFile).to.equal(secondFile.origFile)
      expect(firstFile.file).to.equal(__dirname + '/files/public/generated/js/1.js')

    it "shouldn't matter if staticRoot path isn't 'normalized'" , ->
      @js = new Js(staticRoot:"#{__dirname}/files/public", staticUrlRoot:'/')
      expect(@js.options.staticRoot).to.equal("#{__dirname}/files/public")

  describe 'staticUrlRoot', ->
    it "shouldn't matter if staticUrlRoot ends with / or not", ->
      @js = new Js(staticRoot:"#{__dirname}/files/public", staticUrlRoot:'/url')
      @js.addFile(__dirname + '/files/js/1.js')
      firstFile = @js.files[0]
      @js = new Js(staticRoot:"#{__dirname}/files/public", staticUrlRoot:'/url/')
      @js.addFile(__dirname + '/files/js/1.js')
      secondFile = @js.files[0]
      expect(firstFile.url).to.equal(secondFile.url)
      expect(firstFile.url).to.equal('/url/generated/js/1.js')

    it 'should add the correct url using staticUrlRoot http://www.example.com', ->
      @js = new Js(staticRoot:"#{__dirname}/files/public", staticUrlRoot:'http://www.example.com')
      @js.addFile(__dirname + '/files/js/1.js')
      expect(@js.files[0].url).to.equal('http://www.example.com/generated/js/1.js')

    it 'should add the correct url using staticUrlRoot https://www.example.com/', ->
      @js = new Js(staticRoot:"#{__dirname}/files/public", staticUrlRoot:'https://www.example.com/')
      @js.addFile(__dirname + '/files/js/1.js')
      expect(@js.files[0].url).to.equal('https://www.example.com/generated/js/1.js')
