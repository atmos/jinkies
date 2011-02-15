Helper  = require "./helper"
Vows    = Helper.Vows
assert  = Helper.Assert
Options = Helper.default_options

Vows
.describe("Jenkins Base64 Library")
.addBatch
  "Jenkins Base64 can":
    topic: ->
      new Buffer "Jinkies Paradise"
    "encode strings": (buffer) ->
      assert.equal buffer.toString("base64"), "Smlua2llcyBQYXJhZGlzZQ=="

.export(module)
