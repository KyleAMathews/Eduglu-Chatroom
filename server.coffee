config = require('./config')

# Setup Express and Socket.io.
express = require('express')
app = express.createServer()
io = require('socket.io').listen(app)

io.configure( ->
  io.set('authorization', (handshakeData, callback) ->
    cookies = {}
    handshakeData.headers.cookie && handshakeData.headers.cookie.split(';').forEach (cookie) ->
      parts = cookie.split('=')
      cookies[ parts[ 0 ].trim() ] = ( parts[ 1 ] || '' ).trim()

    # Does it have a valid Drupal UID?
    if cookies.DRUPAL_UID?
      callback(null, true)
    else
      callback(null, false)
  )
)

# Validator
sanitize = require('validator').sanitize

# Setup Mysql client.
mysql = require('mysql')
myclient = mysql.createClient(
  user: config.mysql.user_name
  password: config.mysql.password
)
myclient.query('USE ' + config.mysql.database)

# Setup Redis client.
redis = require 'redis'
rclient = redis.createClient()

# Setup ElasticSearch client.
elastical = require 'elastical'
eclient = new elastical.Client()

# Clear out connected data from Redis on reboot.
rclient.keys("connected:*", (err, res) ->
  for key in res
    rclient.del(key, redis.print)
)

# Setup Express middleware.
app.use express.bodyParser()
app.use express.methodOverride()
app.use app.router
app.use express.static __dirname + '/public'


# Respond to directions from Drupal.
app.post '/drupal', (req, res) ->
  # Check for an api key match.
  if config.drupal.api_key is req.body.data.api_key
    exports[req.body.method](req.body.data)
    res.send 'ok'
  else
    res.send 'bad api_key'

exports.newUser = (data) ->
  rclient.hset('userkey:' + data.key, 'uid', data.uid, redis.print)
  rclient.hset('userkey:' + data.key, 'group', data.group, redis.print)

exports.addGroupie = (data) ->
  io.sockets.in(data.group).emit 'add groupie', data

exports.remGroupie = (data) ->
  io.sockets.in(data.group).emit 'rem groupie', data

# Sockets.io code.
io.sockets.on 'connection', (socket) ->

  socket.on 'chat', (data) ->
    socket.get 'key', (err, key) ->
      rclient.hgetall 'userkey:' + key, (err, res) ->
        unless res.uid? then return

        # Neutralize xss attacks
        data.body = sanitize(data.body).xss()

        data.uid = res.uid
        data.group = res.group

        # Send chat to groupies.
        io.sockets.in(res.group).emit 'chat',
          uid: data.uid
          body: data.body
          date: data.date

        # Save chats to MySQL
        myclient.query(
          'INSERT INTO eduglu_chatroom_chats
           SET uid = ?, gid = ?, date = ?, body = ?',
           [res.uid, res.group, data.date, data.body]
        )

        # Index chats in ElasticSearch.
        eclient.index('chatroom', 'chat', data)

  socket.on 'auth', (key) ->
    # Retrieve the user ID and group ID from Redis and
    # set locally in socket.io and send to the client.
    rclient.hgetall('userkey:' + key, (err, res) ->
      # No key in redis means user not authenticated by Drupal.
      unless res.group? and res.uid? then return
      socket.set('key', key)
      socket.join(res.group)
      socket.emit 'set group', parseInt(res.group, 10)

      socket.emit 'set uid', parseInt(res.uid, 10)

      # Add user to connected set in Redis.
      rclient.sadd('connected:' + res.group, res.uid)

      # Tell everyone about the new user.
      socket.broadcast.to(res.group).emit 'join', [res.uid]

      # Send to current client a list of all connected users.
      rclient.smembers('connected:' + res.group, (err, users) ->
        socket.emit 'join', users
      )
    )

  socket.on 'disconnect', ->
    socket.get 'key', (err, key) ->
      rclient.hgetall 'userkey:' + key, (err, res) ->
        # Inform everyone the user has left and remove them from redis.
        io.sockets.in(res.group).emit 'leave', parseInt(res.uid, 10)
        rclient.srem('connected:' + res.group, res.uid)
        rclient.del('userkey:' + key)

  socket.on 'get older chats', (data) ->
    # A group id needs to be set
    # TODO Check that this is the group the person has access to.
    unless data.gid? then return

    myclient.query(
      'SELECT * FROM eduglu_chatroom_chats
        WHERE date < ? AND gid = ?
        ORDER BY date DESC
        LIMIT 100',
      [data.date, data.gid], (err, results, fields) ->
        socket.emit 'load older chats', results
    )

app.listen config.port
