Helper  = require "./helper"
Vows    = Helper.Vows
assert  = Helper.Assert
Options = Helper.default_options

Job    = require("jinkies").Job

Vows
.describe("Jenkins Job API")
.addBatch
  "Jenkins Jobs can":
    topic: ->
      new Job Options.server, Options.job
    "get the hostname": (job) ->
      assert.equal job.host, Options.server
    "get the job name": (job) ->
      assert.equal job.name, Options.job
  "Jenkins Jobs#builds can":
    topic: ->
      j = new Job Options.server, Options.job
      j.builds @callback
    "get a list of builds": (err, info) ->
      latest = info[0]["number"]
      assert.ok latest.toString().match(/\d+/)
  "Jenkins Jobs#status can":
    topic: ->
      j = new Job Options.server, Options.job
      j.status @callback
    "get the status of a job": (err, status) ->
      assert.equal status, "SUCCESS"
  "Jenkins Jobs#build_for can":
    topic: ->
      j = new Job Options.server, Options.job
      j.build_for 10, @callback
    "get info about a build number": (err, build) ->
      assert.ok    build.status
      assert.equal build.branch, "master"
      assert.equal build.sha1  , "3ba21ee37953c344f698171cb2ab725ef7f9b776"
      assert.equal build.output, "#{Options.server}/job/#{Options.job}/10/consoleText"

.export(module)
