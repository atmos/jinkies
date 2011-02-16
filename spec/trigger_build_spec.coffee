Helper  = require "./helper"
Vows    = Helper.Vows
assert  = Helper.Assert
Options = Helper.default_options

Job    = require("jinkies").Job

Vows
.describe("Jenkins Job Build Trigger API")
.addBatch
  "Jenkins Jobs Build can":
    topic: ->
      j = new Job Options.server, Options.job
      j.triggerBuild "master", "{}", @callback

    "trigger a build": (err, data) ->
      assert.ok data.status

.export(module)
