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
        key: GetCookie('rediskey')
    )

    # Load recent chats for this group.
    app.collections.chats = new Chats()
    app.collections.chats.fetch(
      data:
        gid: Drupal.settings.chatroom.group.nid
        key: GetCookie('rediskey')
    )

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
    socket.emit 'auth', GetCookie('rediskey')

  socket.on 'set uid', (data) ->
    Drupal.settings.chatroom.currentUser = data

  socket.on 'set group', (data) ->
    Drupal.settings.chatroom.group.nid = data

  socket.on 'chat', (data) ->
    chat = new Chat( body: data.body, uid: data.uid )
    app.collections.chats.add(chat)

  socket.on 'join', (uids) ->
    for uid in uids
      uid = parseInt(uid)
      app.collections.users.get(uid).set( connected: true )

  socket.on 'leave', (uid) ->
    app.collections.users.get(uid).set( connected: false )

# Helper functions

# Create a cookie with the specified name and value.
window.SetCookie = (sName, sValue) ->
  document.cookie = sName + "=" + escape(sValue)
  # Expires the cookie in one month
  date = new Date()
  date.setMonth(date.getMonth()+1)
  document.cookie += ("; expires=" + date.toUTCString())

# Retrieve the value of the cookie with the specified name.
window.GetCookie = (sName) ->
  # cookies are separated by semicolons
  aCookie = document.cookie.split("; ")
  for i in [0..aCookie.length]
    # a name/value pair (a crumb) is separated by an equal sign
    aCrumb = aCookie[i].split("=")
    if (sName == aCrumb[0])
      return unescape(aCrumb[1])

    # a cookie with the requested name does not exist
  return null
