HTTPS   = require "https"

class User
  constructor: (@data) ->
    @login = @data.login

  memberOf: (name, callback) ->
    path     = "/api/v2/json/user/show/#{@login}/organizations"
    params   = { host: "github.com", path: path }
    isMember = false

    console.log path
    req = HTTPS.request params, (res) ->
      body = ""
      res.setEncoding "utf8"
      res.on "end", ->
        orgs = JSON.parse body
        orgs.organizations.forEach (element) ->
          if element.login == name
            isMember = true

        callback null, isMember
      res.on "data", (chunk) ->
        body += chunk
    req.end()

exports.User = User
