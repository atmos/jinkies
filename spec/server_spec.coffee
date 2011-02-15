Helper  = require "./helper"
Vows    = Helper.Vows
assert  = Helper.Assert
Options = Helper.default_options

Server  = require("jinkies").Server

Vows
.describe("Jenkins Server API")
.addBatch
  "Jenkins Servers can":
    topic: ->
      new Server Options.server
    "get the hostname": (jenkins) ->
      assert.equal jenkins.host, Options.server
    "parse the hostname": (jenkins) ->
      assert.ok Options.server.match("#{jenkins.url.hostname}")
    "parse the port number": (jenkins) ->
      assert.ok jenkins.url.port.match(/\d+/)
  "Jenkins Server#job_names":
    topic: ->
      s = new Server Options.server
      s.job_names @callback

    "list the job names": (err, results) ->
      found = (name for name in results when name == Options.job)
      assert.equal found, Options.job

  "Jenkins Server#jobs":
    topic: ->
      s = new Server Options.server
      s.jobs @callback

    "list the jobs": (err, results) ->
      found = (job for job in results when job.name == Options.job)[0]
      assert.equal found.url,   "#{Options.server}/job/#{Options.job}/"
      assert.equal found.name,  Options.job
      assert.equal found.color, 'blue'

  "Jenkins.job can":
    topic: ->
      j = new Server Options.server
      j.job_for(Options.job)
    "get the hostname": (job) ->
      assert.equal job.host, Options.server
    "get the job name": (job) ->
      assert.equal job.name, Options.job

.export(module)
