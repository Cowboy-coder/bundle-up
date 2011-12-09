suite = require("jasmine-node")
Js = require "./../lib/js"
Css = require "./../lib/css"
helper = require "./helper"
fs = require "fs"

describe "Path normalizing", ->
  beforeEach ->
    helper.beforeEach()

  it "shouldn't matter if staticRoot ends with / or not", ->
    @js = new Js(staticRoot:"#{__dirname}/files/public", staticUrlRoot:"/")
    @js.addFile(__dirname + "/files/js/1.js")
    firstFile = @js.files[0]
    @js = new Js(staticRoot:"#{__dirname}/files/public/", staticUrlRoot:"/")
    @js.addFile(__dirname + "/files/js/1.js")
    secondFile = @js.files[0]
    expect(firstFile.file).toEqual(secondFile.file)
    expect(firstFile.origFile).toEqual(secondFile.origFile)
    expect(firstFile.file).toEqual(__dirname + "/files/public/generated/js/1.js")

  it "shouldn't matter if staticUrlRoot ends with / or not", ->
    @js = new Js(staticRoot:"#{__dirname}/files/public", staticUrlRoot:"/url")
    @js.addFile(__dirname + "/files/js/1.js")
    firstFile = @js.files[0]
    @js = new Js(staticRoot:"#{__dirname}/files/public", staticUrlRoot:"/url/")
    @js.addFile(__dirname + "/files/js/1.js")
    secondFile = @js.files[0]
    expect(firstFile.url).toEqual(secondFile.url)
    expect(firstFile.url).toEqual("/url/generated/js/1.js")
