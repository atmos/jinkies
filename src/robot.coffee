Campfire     = require("jenkins/utils/campfire").Campfire
HttpRequest  = require("jenkins/utils/http_request").HttpRequest
EventEmitter = require("events").EventEmitter

class Build
  constructor: (@job, @number) ->

  info: (callback) ->
    @job.client.fetch "/jobs/#{@job.name}/builds/#{@number}", (err, data) ->
      callback err, data

  notify: (callback) ->
    self = @
    @info (err, data) ->
      sha      = data.sha1.slice(0,7)
      number   = data.number
      branch   = data.branch
      reply    = "Build ##{number} (#{sha}) of #{self.job.name}/#{branch}"
      compare  = data.payload && data.payload.compare
      duration = data.data.duration / 1000 || 0.0

      switch data.status
        when "successful"
          reply += " was successful "
        when "failed"
          reply += " failed "
        when "building"
          reply += " building now "
        else
          reply += " unknown[#{data.status}] "

      self.status = data.status

      reply += "(#{Math.floor(duration)}s)."
      reply += " #{compare}" if compare

      callback err, self, reply, data.consoleText

class Job
  constructor: (@client, @name) ->
    @number = 1

  poll: (callback) ->
    self = @
    @client.fetch "/jobs/#{@name}", (err, data) ->
      if data.lastCompletedBuild.number > self.number
        self.number = data.lastCompletedBuild.number
        build = new Build(self, self.number)
        build.notify (err, build, notification, output) ->
          callback err, build, notification, output

      setTimeout (->
        self.poll callback
      ), 15000

class Robot extends EventEmitter
  constructor: (@host) ->
    @client = new HttpRequest(@host)

  findJobs: (callback) ->
    client = @client
    client.fetch "/jobs", (err, data) ->
      for job in data
        do (job) ->
          callback err, new Job(client, job.name)

  run: (callback) ->
    self = @
    @findJobs (err, job) ->
      job.poll (err, build, notification, output) ->
        self.emit("build", err, build, notification, output)

class CampfireRobot
  constructor: (@host, @options) ->
    @robot    = new Robot(@host)
    @campfire = new Campfire(@options)
    @room     = @campfire.Room(@options.room)

  run: ->
    room = @room
    @robot.on "build", (err, build, notification, output) ->
      room.speak notification, (err, data) ->
        console.log "Sent: #{notification}"
        if build.status == "failed"
          room.paste output, (err, data) ->
            console.log "Pasted failures"
    @robot.run()

exports.Robot         = Robot
exports.CampfireRobot = CampfireRobot
