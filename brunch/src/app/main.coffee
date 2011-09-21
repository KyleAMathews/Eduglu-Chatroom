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

    # Load users for this group.
    app.collections.users = new Users()
    app.collections.users.fetch(
      data:
        gid: Drupal.settings.chatroom.group.nid
    )

    # Load recent chats for this group.
    app.collections.chats = new Chats()
    app.collections.chats.fetch()

    app.views.home = new HomeView( el: '#main-content' )
    app.routers.main.navigate 'home', true if Backbone.history.getFragment() is ''

  # Initialize the app.
  app.initialize()
  Backbone.history.start()

  # Initialize Socket.io.
  window.socket = io.connect('http://localhost:3000')

  socket.on 'connect', ->
    app.collections.users.currentUser =
      app.collections.users.get(Drupal.settings.chatroom.currentUser)
    socket.emit 'set uid', Drupal.settings.chatroom.currentUser

  socket.on 'chat', (data) ->
    chat = new Chat( body: data.body, uid: data.uid )
    app.collections.chats.add(chat)

  socket.on 'join', (uid) ->
    app.collections.users.get(uid).set( connected: true )

  socket.on 'leave', (uid) ->
    app.collections.users.get(uid).set( connected: false )
