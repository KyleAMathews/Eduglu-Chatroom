messageTemplate = require('templates/message')

class exports.ChatView extends Backbone.View
  className: 'chat-message'
  tagName: 'p'

  render: =>
    $(@el).html messageTemplate( model: @model )
    @
