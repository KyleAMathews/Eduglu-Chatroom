User = require('models/user').User

class exports.Users extends Backbone.Collection
  model: User

  url: 'http://localhost:3000/Users'

  currentUserUID: =>
    return @currentUser.get("uid")
