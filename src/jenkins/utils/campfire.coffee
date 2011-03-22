HTTPS        = require "https"
EventEmitter = require("events").EventEmitter

class Campfire extends EventEmitter
  constructor: (options) ->
    @token         = options.token
    @rooms         = options.rooms and options.rooms.split(",")
    @account       = options.account
    @domain        = @account + ".campfirenow.com"
    @authorization = "Basic " + new Buffer("#{@token}:x").toString("base64")

  Rooms: (callback) ->
    @get "/rooms", callback

  User: (id, callback) ->
    @get "/users/#{id}", callback

  Me: (callback) ->
    @get "/users/me", callback

  Room: (id) ->
    self = @

    show: (callback) ->
      self.post "/room/#{id}", "", callback
    join: (callback) ->
      self.post "/room/#{id}/join", "", callback
    leave: (callback) ->
      self.post "/room/#{id}/leave", "", callback
    lock: (callback) ->
      self.post "/room/#{id}/lock", "", callback
    unlock: (callback) ->
      self.post "/room/#{id}/unlock", "", callback

    # say things to this channel on behalf of the token user
    paste: (text, callback) ->
      @message text, "PasteMessage", callback
    sound: (text, callback) ->
      @message text, "SoundMessage", callback
    speak: (text, callback) ->
      @message text, "TextMessage", callback
    message: (text, type, callback) ->
      body = { message: { "body":text, "type":type } }
      self.post "/room/#{id}/speak", body, callback

    # listen for activity in channels
    listen: ->
      headers =
        "Host"          : "streaming.campfirenow.com",
        "Authorization" : self.authorization

      options =
        "host"   : "streaming.campfirenow.com"
        "port"   : 443
        "path"   : "/room/#{id}/live.json"
        "method" : "GET"
        "headers": headers

      request = HTTPS.request options, (response) ->
        response.setEncoding("utf8")
        response.on "data", (chunk) ->
          #console.log "#{new Date}: Received #{id} \"#{chunk}\""
          if chunk.match(/^\S+/)
            try
              chunk.split("\r").forEach (part) ->
                data = JSON.parse part

                self.emit data.type, data.id, data.created_at, data.room_id, data.user_id, data.body
                data

        response.on "end", ->
          console.log "Streaming Connection closed. :("

        response.on "error", (err) ->
          console.log err
      request.end()
      request.on "error", (err) ->
        console.log err
        console.log err.stack

  # Convenience HTTP Methods for posting on behalf of the token"d user
  get: (path, callback) ->
    @request "GET", path, null, callback

  post: (path, body, callback) ->
    @request "POST", path, body, callback

  request: (method, path, body, callback) ->
    headers =
      "Authorization" : @authorization
      "Host"          : @domain
      "Content-Type"  : "application/json"

    options =
      "host"   : @domain
      "port"   : 443
      "path"   : path
      "method" : method
      "headers": headers

    if method == "POST"
      if typeof(body) != "string"
        body = JSON.stringify body
      options.headers["Content-Length"] = body.length

    request = HTTPS.request options, (response) ->
      data = ""
      response.on "data", (chunk) ->
        data += chunk
      response.on "end", ->
        try
          callback null, JSON.parse(data)
        catch err
          callback null, data || { }
      response.on "error", (err) ->
        callback err, { }

    if method == "POST"
      request.end(body)
    else
      request.end()
    request.on "error", (err) ->
      console.log err
      console.log err.stack

exports.Campfire = Campfire
