Users = require('collections/users').Users
userTemplate = require('templates/user')
connectedTemplate = require('templates/connected')

class exports.ConnectedView extends Backbone.View

  initialize: ->
    @el = $('#block-boxes-chatroom_connected')

    # Set the width
    $(@el).css('width', $("#sidebar-right").width())

    $(@el).html(connectedTemplate())

    @collection.bind('change:connected', @render)
    @collection.bind('reset', @render)

    app.settings.bind('change:connection_status', @status)

  render: =>
    @$('#connected').empty()
    @$('#connected').append('<h2>Connected (' + @collection.connected().length + ')</h2>')
    for user in @collection.connected()
      @$('#connected').append userTemplate( user: user )

  status: (status) =>
    if status.get("connection_status") is "disconnected"
      @$('#connected').addClass('disconnected')
      @$('#connected').removeClass('connected')

    if status.get("connection_status") is "connected"
      @$('#connected').addClass('connected')
      @$('#connected').removeClass('disconnected')

