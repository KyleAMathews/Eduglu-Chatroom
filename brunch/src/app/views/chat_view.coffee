chatTemplate = require('templates/chat')

class exports.ChatView extends Backbone.View
  className: 'chat'
  tagName: 'li'

  render: =>
    user = app.collections.users.get(@model.get("uid"))
    $(@el).html chatTemplate( model: @model, user: user )
    @
