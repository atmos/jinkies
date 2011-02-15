Helper   = require "./helper"
Vows     = Helper.Vows
assert   = Helper.Assert
Options  = Helper.default_options

Campfire = require("jenkins/utils/campfire").Campfire

Vows
.describe("Jenkins Campfire Library")
.addBatch
  "Jenkins Campfire can":
    topic: ->
      new Campfire({"token": Options.campfire.token, "account": Options.campfire.account})
    "retrieve its token": (campfire) ->
      assert.equal campfire.token, Options.campfire.token
    "retrieve its account name": (campfire) ->
      assert.equal campfire.account, Options.campfire.account
  #"Jenkins Campfire Users can":
    #topic: ->
      #cf = new Campfire({"token": Options.campfire.token, "account": Options.campfire.account})
      #cf.User Options.campfire.user, @callback
    #"retrieves a user's information": (user) ->
      #console.log user
  "Jenkins Campfire Rooms can":
    topic: ->
      cf = new Campfire({"token": Options.campfire.token, "account": Options.campfire.account})
      cf.Rooms @callback
    "retrieves a list of rooms": (rooms) ->
      console.log rooms
  "Jenkins Campfire Rooms can":
    topic: ->
      cf   = new Campfire({"token": Options.campfire.token, "account": Options.campfire.account})
      room = cf.Room(Options.campfire.room)
      room.speak "Vows Test Post", @callback
    "retrieve its token": (err, data) ->
      assert.equal "Vows Test Post", data.message.body

.export(module)
