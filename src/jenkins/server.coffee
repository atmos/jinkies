Job         = require("jenkins/job").Job
Build       = require("jenkins/build").Build
HttpRequest = require("jenkins/utils/http_request").HttpRequest

class Server
  constructor: (@host) ->
    @client = new HttpRequest(@host)
    @url    = @client.url

  job_for: (name) ->
    new Job @host, name

  job_names: (callback) ->
    @jobs (err, jobs) ->
      callback err, (job.name for job in jobs)

  jobs: (callback) ->
    @client.fetch "/api/json", (err, data) ->
      callback err, data.jobs

exports.Job    = Job
exports.Build  = Build
exports.Server = Server
