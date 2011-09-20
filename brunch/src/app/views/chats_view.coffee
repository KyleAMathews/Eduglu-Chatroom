Chats = require('collections/chats').Chats
chatView = require('views/chat_view').ChatView

class exports.ChatsView extends Backbone.View
  id: 'chats'
  tagName: 'ul'

  initialize: ->
    @collection.bind('add', @addOne)

  render: =>
    console.log "trying to render ChatsView"
    @collection.each (chat) =>
      @addOne(chat)
    @

  addOne: (chat) =>
    view = new chatView( model: chat )
    $(@el).append(view.render().el)
    @
