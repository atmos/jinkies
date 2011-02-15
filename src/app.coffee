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
    res.send data, {"Content-Type"; "application/json"}, data.status

app.get "/jobs", (req, res) ->
  app.jinkies.jobs (err, jobs) ->
    res.send jobs, {"Content-Type"; "application/json"}, 200

app.get "/jobs/:name", (req, res) ->
  job = app.jinkies.job_for req.params.name
  job.info (err, info) ->
    res.send info, {"Content-Type"; "application/json"}, 200

app.get "/jobs/:name/build/:number", (req, res) ->
  job = app.jinkies.job_for req.params.name
  job.build_for req.params.number, (err, build) ->
    res.send build, {"Content-Type"; "application/json"}, 200

exports.App = app
