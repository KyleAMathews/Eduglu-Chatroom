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
Users      = require('collections/users').Users

# app bootstrapping on document ready
$(document).ready ->
  app.initialize = ->
    app.routers.main = new MainRouter()
    app.models.chat = Chat

    app.collections.users = new Users()
    app.collections.users.fetch() # Temporary until I get group loading working.
    app.collections.chats = new Chats()
    app.collections.chats.fetch()

    app.views.home = new HomeView( el: '#main-content' )
    app.routers.main.navigate 'home', true if Backbone.history.getFragment() is ''
  app.initialize()
  Backbone.history.start()

  # Init Socket.io.
  window.socket = io.connect('http://localhost:3000')
  socket.on 'chat', (data) ->
    chat = new Chat( body: data.body, uid: data.uid )
    app.collections.chats.add(chat)
