User = require('models/user').User

class exports.Users extends Backbone.Collection
  model: User

  currentUserUID: =>
    return @currentUser.get("uid")

  connected: =>
    @filter (user) ->
      return user.get("connected") is true
