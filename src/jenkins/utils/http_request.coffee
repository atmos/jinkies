Url  = require 'url'
Http = require 'http'

class HttpRequest
  constructor: (@host) ->
    @url      = Url.parse @host
    @port     = @url.port
    @path     = @url.pathname || ""
    @hostname = @url.hostname

  fetch: (path, callback) ->
    result = ""
    client = Http.createClient @port, @hostname

    client.on 'error', (err) ->
      console.log "Unable to connect to #{@host}, did you set a JENKINS_SERVER environmental variable?"
      callback(err, { })

    request = client.request 'GET', "#{@path}#{path}", {'host': @hostname }
    request.on 'response', (response) ->
      response.on 'end', ->
        if response.statusCode == 200
          callback null, JSON.parse(result)
        else
          callback null, { 'error': response.statusCode, 'actions': [ ], 'jobs': [ ] } # shady
      response.on 'data', (chunk) ->
        result += chunk
      response.on 'error', (err) ->
        callback err, { }
    request.end()

exports.HttpRequest = HttpRequest
