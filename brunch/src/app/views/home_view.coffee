homeTemplate = require('templates/home')
ChatsView = require('views/chats_view').ChatsView
ConnectedView = require('views/connected_view').ConnectedView

class exports.HomeView extends Backbone.View
  id: 'home-view'

  render: ->
    $(@el).html homeTemplate( name: Drupal.settings.chatroom.group.name )
    chatsView = new ChatsView( collection: app.collections.chats )
    $(@el).append chatsView.render().el
    connectedView = new ConnectedView( collection: app.collections.users )
    connectedView.render()
    @
