Chat = require('models/chat').Chat

class exports.Chats extends Backbone.Collection
  model: Chat

  addOlderChats: (chats) =>
    for chat in chats
      # Add to the chat collection, set silent to avoid triggering
      # the addOne() function.
      chatModel = new app.models.chat(chat)
      @add(chatModel, silent:true)
      # Call our special prependOne function to prepend the chat.
      app.views.chatsView.prependOne(chatModel)

  comparator: (chat) =>
    chat.get('date')
