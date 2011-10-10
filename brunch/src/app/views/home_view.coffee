homeTemplate = require('templates/home')
ConnectedView = require('views/connected_view').ConnectedView

class exports.HomeView extends Backbone.View
  id: 'home-view'

  render: ->
    $(@el).html homeTemplate( name: Drupal.settings.chatroom.group.name )
    $(@el).append app.views.chatsView.render().el
    connectedView = new ConnectedView( collection: app.collections.users )
    connectedView.render()

    # Load older chats
    $('#load-older-chats').click( ->
      socket.emit 'get older chats',
        gid: Drupal.settings.chatroom.group.nid,
        date: app.collections.chats.at(0).get('date')
    )
    @
