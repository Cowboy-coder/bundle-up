program = require 'commander'

program
  .version((require './../package.json').version)
  .usage('[options] <your express app>')
  .option('--build', "Build the assets - exits directly after app.use(BundleUp(...));")

program.on '--help', ->
  console.log '  Examples:'
  console.log ''
  console.log '  --build:'
  console.log '    # Will execute server.js (works for .coffee as well) to build'
  console.log '    # the assets files. Everything happens synchronously as soon as'
  console.log '    # app.use(BundleUp(...)) is excuted and exits right after.'
  console.log '    $ bundleup --build server.js'
  console.log ''

program.parse(process.argv)

file = program.args[0]

unless file
  console.log "No <server.js>-file provided"
  process.exit(1)

if program.build
  process.env.bundle_exec = 'build'
  require "#{process.cwd()}/#{file}"
