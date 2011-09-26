Chats = require('collections/chats').Chats
chatView = require('views/chat_view').ChatView
chatsTemplate = require('templates/chats')
userContainerTemplate = require('templates/userContainer')

class exports.ChatsView extends Backbone.View
  id: 'chats'
  lastUserContainer = 0

  initialize: ->
    @dateCount = 5
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

    # Refresh dates every five seconds.
    setInterval((-> $('span.humaneDate').humaneDates()), 5000)
    @

  addOne: (chat) =>
    view = new chatView( model: chat )
    user = app.collections.users.get(chat.get('uid'))

    # If user different than the last user, create a new user container.
    if chat.get('uid') isnt @lastUserContainer
      # Only add the Date every five user containers.
      addDate = false
      if @dateCount is 5
        addDate = true
        @dateCount = 1
      else
        @dateCount++

      @$('ul').append(userContainerTemplate( user: user, addDate: addDate, date: chat.get("date")))

      # Fade in the new user container.
      @$('ul li:last').hide().fadeIn()

      # Change dates to use 'x time ago' format.
      @$('.humaneDate').humaneDates()

      @lastUserContainer = user.id

    # Add the message to the current user container.
    @$(".chat-messages").filter(":last").append( view.render().el )
    @

  sendChat: (e) =>
    return if e.keyCode isnt 13
    return if $(e.target).val() is ""
    d = new Date()
    date = ""
    if typeof d.toISOString is 'function'
      date = d.toISOString()
    else
      date = ISODateString(d)
    socket.emit('chat',
      date: date
      body: $(e.target).val()
    )
    $(e.target).val('')
