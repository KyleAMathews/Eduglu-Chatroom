chatTemplate = require('templates/chat')

class exports.ChatView extends Backbone.View
  className: 'chat'
  tagName: 'li'

  render: =>
    console.log $(@el)
    console.log @model
    $(@el).html chatTemplate( model: @model )
    @
