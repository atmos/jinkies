Path    = require "path"
Express = require "express"

app     = Express.createServer()

app.configure ->
  app.use Express.logger()
  app.use Express.methodOverride()
  app.use Express.bodyDecoder()
  app.use Express.errorHandler({ showStack: true, dumpExceptions: true })

app.post "/", (req, res) ->
  info    = JSON.parse(req.body.payload)
  owner   = info.repository.owner.name
  branch  = info["ref"].split("/")[2]

  project = "#{owner}-#{info.repository.name}"

  job = app.jinkies.job_for project
  job.triggerBuild branch, req.body.payload, (err, data) ->
    res.send data, {"Content-Type"; "application/json"}, 200

app.get "/jobs", (req, res) ->
  app.jinkies.jobs (err, jobs) ->
    res.send jobs, {"Content-Type"; "application/json"}, 200

app.get "/jobs/:job", (req, res) ->
  job = app.jinkies.job_for req.params.job
  job.info (err, info) ->
    res.send info, {"Content-Type"; "application/json"}, 200

app.post "/jobs/:job/builds", (req, res) ->
  job = app.jinkies.job_for req.params.job
  branch_name = req.body.branch || "master"
  job.triggerBuild branch_name, "{}", (err, data) ->
    res.send data, {"Content-Type"; "application/json"}, 200

app.get "/jobs/:job/builds/:build", (req, res) ->
  job = app.jinkies.job_for req.params.job
  job.build_for req.params.build, (err, build) ->
    res.send build, {"Content-Type"; "application/json"}, 200

app.get "/jobs/:job/branches/:branch", (req, res) ->
  job = app.jinkies.job_for req.params.job
  job.branches_for req.params.branch, (err, branches) ->
    res.send branches, {"Content-Type"; "application/json"}, 200

exports.App = app
