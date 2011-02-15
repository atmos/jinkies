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
    @info (err, data) ->
      callback err, data.builds

  status: (callback) ->
    @info (err, data) ->
      callback err, data.color == "blue"

  build_for: (number, callback) ->
    host = @host
    name = @name
    @client.fetch "/job/#{@name}/#{number}/api/json", (err, data) ->
      build = new Build host, name, number, data
      callback err, build

  triggerBuild: (branch, payload, callback) ->
    req = new BuildRequest @client.url, @name, branch, payload
    req.trigger (err, data) ->
      callback err, data

exports.Job   = Job
