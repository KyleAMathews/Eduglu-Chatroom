chatTemplate = require('templates/chat')

class exports.ChatView extends Backbone.View
  className: 'chat'
  tagName: 'li'

  render: =>
    $(@el).html chatTemplate( model: @model )
    @
