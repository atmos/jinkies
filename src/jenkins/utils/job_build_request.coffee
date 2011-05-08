Url         = require 'url'
Http        = require 'http'
QueryString = require 'querystring'

class JobBuildRequest
  constructor: (@url, @name, @branch, @payload) ->
    @port     = @url.port
    @path     = "/job/#{@name}/build"
    @hostname = @url.hostname

    @options  =
      parameter: [
        {'name': 'GITHUB_BRANCH',  'value': @branch},
        {'name': 'GITHUB_PAYLOAD', 'value': @payload}
      ]

  trigger: (callback) ->
    result  = ""
    client  = Http.createClient(@port, @hostname)
    client.on 'error', (err) ->
      console.log "Unable to connect to #{@host}, did you set a JENKINS_SERVER environmental variable?"
      callback err, { }

    data = QueryString.stringify({json:JSON.stringify(@options)}, '&', '=', false)

    postParams =
      'host':           @hostname
      'Content-Length': data.length
      'Content-Type':   'application/x-www-form-urlencoded'

    request = client.request 'POST', @path, postParams
    request.on 'response', (response) ->
      response.on 'end', ->
        callback null, {'status': response.statusCode == 302}
      response.on 'data', (chunk) ->
        result += chunk
      response.on 'error', (err) ->
        callback err, { }
    request.end data

exports.JobBuildRequest = JobBuildRequest
