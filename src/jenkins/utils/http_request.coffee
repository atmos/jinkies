Url  = require "url"
Http = require "http"

class HttpRequest
  constructor: (@host) ->
    @url      = Url.parse @host
    @port     = @url.port
    @path     = @url.pathname || ""
    @hostname = @url.hostname

  fetch: (path, callback) ->
    result = ""
    headers =
      "Accept": "application/json"

    params =
      "host":    @hostname
      "port":    @port
      "path":    "#{@path}#{path}"
      "headers": headers

    request = Http.request params, (response) ->
      response.on "end", ->
        if response.statusCode == 200
          callback null, JSON.parse(result)
        else
          callback null, { "error": response.statusCode, "actions": [ ], "jobs": [ ] } # shady
      response.on "data", (chunk) ->
        result += chunk
      response.on "error", (err) ->
        callback err, { }
    request.end()

exports.HttpRequest = HttpRequest
