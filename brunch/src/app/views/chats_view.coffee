Chats = require('collections/chats').Chats
chatView = require('views/chat_view').ChatView
chatsTemplate = require('templates/chats')
userContainerTemplate = require('templates/userContainer')

class exports.ChatsView extends Backbone.View
  id: 'chats'
  lastUserContainer = 0

  initialize: ->
    @lastUserContainerId = 0
    @bulkLoading = false
    @dateCount = 5
    @collection.bind('add', @addOne)
    @collection.bind('reset', @render)

  render: =>
    $(@el).html chatsTemplate()
    # Manually bind event as we're using a jQuery version older than 1.42 when
    # $.delegate was added so we can't use the normal backbone way of adding events.
    @$('.enter-chat').bind('keypress', (e) =>
      @sendChat(e)
    )
    @bulkLoading = true
    @collection.each (chat) =>
      @addOne(chat)
    @bulkLoading = false

    # Refresh dates every five seconds.
    setInterval((-> $('span.humaneDate').humaneDates()), 5000)
    @

  prependOne: (chat) =>
    chat.prepend = true
    @addOne(chat)

  addOne: (chat) =>
    view = new chatView( model: chat )
    user = app.collections.users.get(chat.get('uid'))
    scrollDown = =>
      unless @bulkLoading
        # If within 10% of the bottom, scrolldown.
        docHeight = $(document).height()
        distanceToBottom = docHeight - ($(window).height() + $(window).scrollTop())
        if distanceToBottom / docHeight <= .1
          $('html, body').animate
             scrollTop: $(document).height()-$(window).height(),
             500

    # Create a new user container if the user is different than the last user.
    if parseInt(chat.get('uid'), 10) isnt parseInt(@currentUser, 10)
      @lastUserContainerId++

      # Only add the Date every five user containers.
      addDate = false
      if @dateCount is 5
        addDate = true
        @dateCount = 1
      else
        @dateCount++

      if chat.prepend?
        @$('ul').prepend(userContainerTemplate( user: user, addDate: addDate, date: chat.get("date"), id: @lastUserContainerId))
      else
        @$('ul').append(userContainerTemplate( user: user, addDate: addDate, date: chat.get("date"), id: @lastUserContainerId))

      # Fade in the new user container.
      @$('ul li:last').hide().fadeIn()

      # Change dates to use 'x time ago' format.
      @$('.humaneDate').humaneDates()

      @currentUser = user.id

    # Add the message to the current user container.
    @$("#" + @lastUserContainerId).find('.chat-messages').append view.render().el
    scrollDown()
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
