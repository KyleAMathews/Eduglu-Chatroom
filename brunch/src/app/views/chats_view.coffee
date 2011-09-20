Chats = require('collections/chats').Chats
chatView = require('views/chat_view').ChatView
chatsTemplate = require('templates/chats')

class exports.ChatsView extends Backbone.View
  id: 'chats'

  initialize: ->
    @collection.bind('add', @addOne)
    @collection.bind('reset', @render)

  render: =>
    $(@el).html chatsTemplate()
    # Manually bind event as we're using a jQuery version older than 1.42 when
    # $.delegate was added so we can use the normal backbone way of adding events.
    @$('.enter-chat').bind('keypress', (e) =>
      @sendChat(e)
    )
    @collection.each (chat) =>
      @addOne(chat)
    @

  addOne: (chat) =>
    view = new chatView( model: chat )
    @$('ul').append(view.render().el)
    @

  sendChat: (e) =>
    return if e.keyCode isnt 13
    return if $(e.target).val() is ""
    socket.emit('chat',
      body: $(e.target).val()
      uid: app.collections.users.currentUserUID()
    )
    $(e.target).val('')
