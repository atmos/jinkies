Url  = require("url")
Http = require("http")

class Build
  constructor: (@host, @name, @number, @data) ->
    @sha1     = "0000000000000000000000000000000000000000"
    @branch   = "master"
    @compare  = ""
    @output   = "#{@host}/job/#{@name}/#{@number}/consoleText"

    switch @data.result
      when "SUCCESS"
        @status = "successful"
      when "FAILURE"
        @status = "failed"
      else # null
        @status = "building"

    @statusClass = @statusClass()

    info = (action for action in @data.actions when action.parameters)
    if info[0]
      params  = info[0].parameters

      @branch = (hash.value for hash in params when hash.name == "GITHUB_BRANCH")[0]
      payload = (hash.value for hash in params when hash.name == "GITHUB_PAYLOAD")[0]

      if payload && payload.length > 2
        try
          @payload = payload.slice(1, payload.length - 1) # strip beginning and end quote :\
          @payload = JSON.parse @payload
          @sha1    = @payload.after             if @payload.after
          @branch  = @payload.ref.split("/")[2] if @payload.ref

  consoleText: (callback) ->
    result = ""
    url   = Url.parse @output

    client = Http.createClient url.port, url.hostname
    client.on 'error', (err) ->
      console.log url
      console.log "Unable to connect to #{@host}, did you set a JENKINS_SERVER environmental variable?"
      callback(err, { })

    request = client.request 'GET', url.pathname, {'host': url.hostname }
    request.on 'response', (response) ->
      response.on 'end', ->
        if response.statusCode == 200
          callback null, result
        else
          callback null, "Unable to fetch the output\nWTF\n"
      response.on 'data', (chunk) ->
        result += chunk
      response.on 'error', (err) ->
        callback err, { }
    request.end()

  statusClass: ->
    switch @status
      when 'successful'
        'good'
      when 'building'
        'building'
      else
        'janky'

exports.Build = Build
