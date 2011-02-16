Map          = require("async").map
Build        = require("jenkins/build").Build
HttpRequest  = require("jenkins/utils/http_request").HttpRequest
BuildRequest = require("jenkins/utils/job_build_request").JobBuildRequest

class Job
  constructor: (@host, @name) ->
    @client = new HttpRequest @host

  info: (callback) ->
    @client.fetch "/job/#{@name}/api/json", (err, data) ->
      callback err, data

  builds: (callback) ->
    self = @
    @info (err, data) ->
      numbers   = (hash.number for hash in data.builds)
      build_for =
        self.build_for.bind(self)
      Map numbers, build_for, (err, results) ->
        callback err, results

  status: (callback) ->
    @branches_for 'master', (err, branches) ->
      branch = branches[0] || { status: 'failed' }
      callback err, branch.status

  build_for: (number, callback) ->
    host = @host
    name = @name
    @client.fetch "/job/#{@name}/#{number}/api/json", (err, data) ->
      build = new Build host, name, number, data
      callback err, build

  branches_for: (branch, callback) ->
    self = @
    @builds (err, data) ->
      results = (hash for hash in data when hash.branch == branch)
      callback err, results[0..10]

  triggerBuild: (branch, payload, callback) ->
    req = new BuildRequest @client.url, @name, branch, payload
    req.trigger (err, data) ->
      callback err, data

exports.Job   = Job
