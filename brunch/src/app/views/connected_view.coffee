Users = require('collections/users').Users
userTemplate = require('templates/user')

class exports.ConnectedView extends Backbone.View

  initialize: ->
    @el = $('#boxes-box-chatroom_connected')
    @collection.bind('change:connected', @render)
    @collection.bind('reset', @render)

  render: =>
    $(@el).empty()
    $(@el).append('<h2>Connected (' + @collection.connected().length + ')</h2>')
    for user in @collection.connected()
      $(@el).append userTemplate( user: user )
