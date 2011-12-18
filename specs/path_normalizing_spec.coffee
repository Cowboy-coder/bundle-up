suite = require 'jasmine-node'
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
      expect(firstFile.file).toEqual(secondFile.file)
      expect(firstFile.origFile).toEqual(secondFile.origFile)
      expect(firstFile.file).toEqual(__dirname + '/files/public/generated/js/1.js')

    it "shouldn't matter if staticRoot path isn't 'normalized'" , ->
      @js = new Js(staticRoot:"#{__dirname}/../specs/files/public", staticUrlRoot:'/')
      expect(@js.options.staticRoot).toEqual("#{__dirname}/files/public")

  describe 'staticUrlRoot', ->
    it "shouldn't matter if staticUrlRoot ends with / or not", ->
      @js = new Js(staticRoot:"#{__dirname}/files/public", staticUrlRoot:'/url')
      @js.addFile(__dirname + '/files/js/1.js')
      firstFile = @js.files[0]
      @js = new Js(staticRoot:"#{__dirname}/files/public", staticUrlRoot:'/url/')
      @js.addFile(__dirname + '/files/js/1.js')
      secondFile = @js.files[0]
      expect(firstFile.url).toEqual(secondFile.url)
      expect(firstFile.url).toEqual('/url/generated/js/1.js')

    it 'should add the correct url using staticUrlRoot http://www.example.com', ->
      @js = new Js(staticRoot:"#{__dirname}/files/public", staticUrlRoot:'http://www.example.com')
      @js.addFile(__dirname + '/files/js/1.js')
      expect(@js.files[0].url).toEqual('http://www.example.com/generated/js/1.js')

    it 'should add the correct url using staticUrlRoot https://www.example.com/', ->
      @js = new Js(staticRoot:"#{__dirname}/files/public", staticUrlRoot:'https://www.example.com/')
      @js.addFile(__dirname + '/files/js/1.js')
      expect(@js.files[0].url).toEqual('https://www.example.com/generated/js/1.js')
