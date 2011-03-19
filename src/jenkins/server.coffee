Job         = require("jenkins/job").Job
Map         = require("async").map
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
    self = @
    @client.fetch "/api/json", (err, data) ->
      callback err, (self.job_for(job.name) for job in data.jobs)

  jobs_info: (callback) ->
    info_callback = (job, infoCallback) ->
      job.branches_for "master", (err, data) ->
        infoCallback err, data[0]

    @jobs (err, jobs) ->
      Map jobs, info_callback, (err, results) ->
        callback err, results

exports.Job    = Job
exports.Build  = Build
exports.Server = Server
