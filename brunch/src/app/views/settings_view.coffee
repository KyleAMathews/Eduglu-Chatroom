class exports.SettingsView extends Backbone.View

  initialize: ->
    @model.bind('change:connection_status', @connection_status_message)

  connection_status_message: (status) =>
    if status.get("connection_status") is "disconnected"
      @setDisconnected()
      status.set( disconnected: true )
      @setMessage("You have lost connection with the chat room. Trying to reconnect.",
      0, 'warning')

    # Only show connected message if this is a reconnection. Socket.io
    # reconnection event isn't firing for some reason.
    if status.get("connection_status") is "connected" and status.get("disconnected")
      @setMessage("You're reconnected!", 3, 'success')
      @setConnected()
      status.set( disconnected: false )

  setMessage: (message = '', seconds = 0, colorclass = 'success') ->
    if message is ''
      $('#chat-message').slideUp('slow')
      return

    $('#chat-message').slideUp('slow', ->
      $('#chat-message').removeClass()
      $('#chat-message').addClass(colorclass)
      $('#chat-message').html(message)
      $('#chat-message').slideDown()
    )
    if seconds isnt 0
      setTimeout((=> @setMessage()), seconds * 1000)

  setDisconnected: ->
    $('input.enter-chat').attr('disabled', 'disabled')

  setConnected: ->
    $('input.enter-chat').removeAttr('disabled')

