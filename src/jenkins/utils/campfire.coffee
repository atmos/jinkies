HTTP   = require "http"

class Campfire
  constructor: (options) ->
    @token         = options.token
    @account       = options.account
    @domain        = @account + ".campfirenow.com"
    @authorization = "Basic " + new Buffer("#{@token}:x").toString('base64')

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
      body = { message: { 'body':text, 'type':type } }
      self.post "/room/#{id}/speak", body, callback

    # listen for activity in channels
    listen: (callback) ->
      path    = "/room/#{id}/live.json"
      headers =
        "Host"          : "streaming.campfirenow.com",
        "Authorization" : self.authorization

      client = HTTP.createClient 443, "streaming.campfirenow.com", true
      request = client.request "GET", path, headers
      request.on "response", (response) ->
        response.setEncoding("utf8")
        response.on "data", (chunk) ->
          if chunk != " "
            for data in chunk.split("\r") when data != ""
              do (data) ->
                callback null, JSON.parse(data)
      request.end()

  # Convenience HTTP Methods for posting on behalf of the token'd user
  get: (path, callback) ->
    @request "GET", path, null, callback

  post: (path, body, callback) ->
    @request "POST", path, body, callback

  request: (method, path, body, callback) ->
    headers =
      "Authorization" : @authorization
      "Host"          : @domain
      "Content-Type"  : "application/json"

    if method == "POST"
      if typeof(body) != "string"
        body = JSON.stringify body
      headers["Content-Length"] = body.length

    client  = HTTP.createClient 443, @domain, true
    request = client.request method, path, headers
    request.on "response", (response) ->
      data = ""
      response.on "data", (chunk) ->
        data += chunk
      response.on "end", ->
        try
          callback null, JSON.parse data
        catch err
          callback null, { }
      response.on 'error', (err) ->
        callback err, { }

    if method == "POST"
      request.write body

    request.end()

exports.Campfire = Campfire
