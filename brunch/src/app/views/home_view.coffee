homeTemplate = require('templates/home')
ChatsView = require('views/chats_view').ChatsView

class exports.HomeView extends Backbone.View
  id: 'home-view'

  render: ->
    $(@el).html homeTemplate( name: Drupal.settings.chatroom.group.name[0] )
    chatsView = new ChatsView( collection: app.collections.chats )
    $(@el).append chatsView.render().el
    @
