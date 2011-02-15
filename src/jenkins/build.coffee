class Build
  constructor: (@host, @name, @number, @data) ->
    @sha1     = "0000000000000000000000000000000000000000"
    @branch   = "master"
    @compare  = ""
    @status   = @data.result == "SUCCESS"
    @output   = "#{@host}/job/#{@name}/#{@number}/consoleText"

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


exports.Build = Build
