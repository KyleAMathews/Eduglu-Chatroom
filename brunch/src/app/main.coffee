window.app = {}
app.routers = {}
app.models = {}
app.collections = {}
app.views = {}

MainRouter = require('routers/main_router').MainRouter
HomeView   = require('views/home_view').HomeView
ChatsView  = require('views/chats_view').ChatsView
Chat       = require('models/chat').Chat
Chats      = require('collections/chats').Chats

# app bootstrapping on document ready
$(document).ready ->
  app.initialize = ->
    app.routers.main = new MainRouter()
    app.models.chat = Chat
    app.collections.chats = new Chats()
    app.views.home = new HomeView( el: '#main-content' )
    app.routers.main.navigate 'home', true if Backbone.history.getFragment() is ''
  app.initialize()
  Backbone.history.start()

  # Init Socket.io.
  window.socket = io.connect('http://localhost:3000')
  socket.on 'chat', (data) ->
    chat = new Chat( body: data.body, uid: data.uid )
    app.collections.chats.add(chat)
