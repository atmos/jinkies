Fs      = require "fs"
Auth    = require "connect-auth"
Path    = require "path"
Express = require "express"

app     = Express.createServer()

Config  =
  scope:       "email,offline_access"
  appId:       process.env.GITHUB_CLIENT_ID
  appSecret:   process.env.GITHUB_CLIENT_SECRET
  callback:    process.env.GITHUB_CALLBACK
  apiPassword: process.env.JINKIES_API_PASSWORD || "password"

apiUserPasswordFunction = (username, password, successCallback, failureCallback) ->
	if username == "api" && password == Config.apiPassword
		successCallback()
	else
		failureCallback()

console.log Path.join(__filename, "..",  "..")

app.configure ->
  app.set "root", Path.join(__filename, "..",  "..")
  app.set "view engine", "ejs"
  app.set "views", Path.join(__filename, "..",  "..", "views")
  app.use Express.logger()
  app.use Express.methodOverride()
  app.use Express.errorHandler({ showStack: true, dumpExceptions: true })
  app.use Express.static Path.join(__filename, "..", "..", "public")
  app.use Express.cookieParser()
  app.use Express.session { secret: process.env.GITHUB_SESSION_SECRET, lifetime: 150000, reapInterval: 10000 }
  app.use(Auth([ Auth.Anonymous(), Auth.Basic({validatePassword: apiUserPasswordFunction}), Auth.Github(Config) ]))
  app.use Express.bodyParser()

app.get "/auth/github/callback", (req, res) ->
  req.authenticate ["github"], (err, success) ->
    if success
      console.log req.getAuthDetails()
      res.redirect "/jobs"
    else
      res.redirect "/auth/failure"

app.get "/auth/failure", (req, res) ->
  res.render "failure", { title: "Unable to Authenticate, bummer." }

app.get "/auth/login", (req, res) ->
  res.render "login", { title: "Login to our Janky CI Server with GitHub!" }

app.get "/auth/logout", (req, res) ->
  req.logout()
  res.redirect("/jobs", 303)

app.all "*", (req, res, next) ->
  if req.is "*/json"
    req.authenticate ["basic"], (err, success) ->
      if success
        next()
      else
        res.send "Unauthorized", 401
  else
    if req.isAuthenticated()
      next()
    else
      res.redirect "/auth/login"

app.post "/", (req, res) ->
  info    = JSON.parse(req.body.payload)
  owner   = info.repository.owner.name
  branch  = info["ref"].split("/")[2]

  project = "#{owner}-#{info.repository.name}"

  if info.deleted or (info.created and info.commits.length == 0)
    # ignore branch deletions, and new branches with no commits
  else
    job = app.jinkies.job_for project
    job.triggerBuild branch, req.body.payload, (err, data) ->
      res.send data, {"Content-Type": "application/json"}, 200

app.get "/jobs", (req, res) ->
  app.jinkies.jobs_info (err, jobs) ->
    if req.is "*/json"
      res.send jobs, {"Content-Type": "application/json"}, 200
    else
      res.render "index", { title: "Janky CI Server", jobs: jobs }

app.get "/jobs/:job", (req, res) ->
  job = app.jinkies.job_for req.params.job
  job.info (err, info) ->
    res.send info, {"Content-Type": "application/json"}, 200

app.post "/jobs/:job/builds", (req, res) ->
  job = app.jinkies.job_for req.params.job
  branch_name = req.body.branch || "master"
  job.triggerBuild branch_name, "{}", (err, data) ->
    res.send data, {"Content-Type": "application/json"}, 200

app.get "/jobs/:job/builds/:build", (req, res) ->
  job = app.jinkies.job_for req.params.job
  job.build_for req.params.build, (err, build) ->
    res.send build, {"Content-Type": "application/json"}, 200

app.get "/jobs/:job/builds/:build/console", (req, res) ->
  name   = req.params.job
  number = req.params.build
  job = app.jinkies.job_for name
  job.build_for number, (err, build) ->
    title = "Build output for #{name} # #{number}"
    res.render "console", { title: title, output: build.consoleText }

app.get "/jobs/:job/branches/:branch", (req, res) ->
  job = app.jinkies.job_for req.params.job
  job.branches_for req.params.branch, (err, branches) ->
    res.send branches, {"Content-Type": "application/json"}, 200

exports.App = app
