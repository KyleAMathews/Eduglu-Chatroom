window.app = {}
app.routers = {}
app.models = {}
app.collections = {}
app.views = {}

MainRouter = require('routers/main_router').MainRouter
HomeView   = require('views/home_view').HomeView
ChatsView  = require('views/chats_view').ChatsView
SettingsView = require('views/settings_view').SettingsView
Chat       = require('models/chat').Chat
User       = require('models/user').User
Settings   = require('models/settings').Settings
Chats      = require('collections/chats').Chats
Users      = require('collections/users').Users

# app bootstrapping on document ready
$(document).ready ->
  app.initialize = ->
    app.routers.main = new MainRouter()

    # Set some models.
    app.models.chat = Chat
    app.models.user = User

    # Load settings model/view
    app.settings = new Settings()
    app.settingsView = new SettingsView( model: app.settings )

    # Load users for this group.
    app.collections.users = new Users()
    app.collections.users.reset(Drupal.settings.chatroom.group.users)

    # Load recent chats for this group.
    app.collections.chats = new Chats()
    app.collections.chats.reset(Drupal.settings.chatroom.group.chats)

    app.views.home = new HomeView( el: '#main-content' )
    app.routers.main.navigate 'home', true if Backbone.history.getFragment() is ''

  # Initialize the app.
  app.initialize()
  Backbone.history.start()

  # Initialize Socket.io.

  window.socket = io.connect(Drupal.settings.chatroom.nodejs_url,
    'reconnect': true,
    'reconnection delay': 500,
    'max reconnection attempts': 20
  )
  # TODO on disconnect, set some sort of message to let client know there's problems
  # plus disable the chat box.
  # Implement events disconnect, reconnect, reconnect_failed -- when disconnect
  # disable. On reconnect, set message saying we're back on then fade off after 5 seconds.

  socket.on 'connect', ->
    app.settings.set(connection_status: 'connected')
    app.collections.users.currentUser =
      app.collections.users.get(Drupal.settings.chatroom.currentUser)
    socket.emit 'auth', GetCookie('rediskey')

  socket.on 'disconnect', ->
    app.settings.set(connection_status: 'disconnected')

  socket.on 'set uid', (data) ->
    Drupal.settings.chatroom.currentUser = data

  socket.on 'set group', (data) ->
    Drupal.settings.chatroom.group.nid = data

  socket.on 'chat', (data) ->
    if parseInt(data.uid) isnt Drupal.settings.chatroom.currentUser
      titleAlert(data.uid, data.body) if data.uid isnt Drupal.settings.chatroom.currentUser
    chat = new Chat( data )
    app.collections.chats.add(chat)

  socket.on 'join', (uids) ->
    for uid in uids
      uid = parseInt(uid)
      app.collections.users.get(uid).set( connected: true )

  socket.on 'leave', (uid) ->
    app.collections.users.get(uid).set( connected: false )

  socket.on 'add groupie', (data) ->
    newUser = new app.models.user(data)
    app.collections.users.add(newUser)

  socket.on 'rem groupie', (data) ->
    app.collections.users.remove(parseInt(data.uid))

################# Helper functions

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

# Function for generating an ISO 8601 complient data string.
# From https://developer.mozilla.org/en/JavaScript/Reference/Global_Objects/Date
window.ISODateString = (d) ->
  pad = (n) ->
    if n<10 then '0'+n else n
  p = d.getUTCFullYear()+'-'
  p += pad(d.getUTCMonth()+1)+'-'
  p += pad(d.getUTCDate())+'T'
  p += pad(d.getUTCHours())+':'
  p += pad(d.getUTCMinutes())+':'
  p += pad(d.getUTCSeconds())+'Z'
  return p

# Make window title blink on new messages.
titleAlert = (uid, body) ->
  # Clear out any old blinkers first.
  if titleTimeOut?
    clearInterval(titleTimeOut)
    document.title = oldTitle
  user = app.collections.users.get(uid)
  msg = user.get('name') + ' said "' + body + '"'
  window.oldTitle = document.title
  window.titleTimeOut = setInterval((->
    if document.title is msg
      document.title = oldTitle
    else
      document.title = msg),
    1000)
  window.onmousemove = ->
    clearInterval(titleTimeOut)
    document.title = oldTitle
    window.onmousemove = null

# Keep sidebar blocks fixed when scrolling.
a = () ->
  b = $(window).scrollTop()
  d = $("#sidebar-right").offset({scroll:false}).top - 50
  c = $("#sidebar-right > div")
  if b > d
    c.css( position:"fixed",top:"50px" )
  else if b <= d
    c.css( position:"relative",top:"" )

$(window).scroll(a);a()
