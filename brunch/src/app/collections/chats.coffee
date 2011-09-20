Chat = require('models/chat').Chat

class exports.Chats extends Backbone.Collection
  model: Chat

  url: 'http://localhost:3000/chats'
