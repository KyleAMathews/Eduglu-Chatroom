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

mysql = require('mysql')
myclient = mysql.createClient(
  user: 'root'
  password: 'password'
)
myclient.query('USE island_byu_edu')

redis = require 'redis'
rclient = redis.createClient()

# Clear out ephemeral data on reboot.
rclient.keys("connected:*", (err, res) ->
  for key in res
    console.log "deleting " + key
    rclient.del(key, redis.print)
)
rclient.keys("userkey:*", (err, res) ->
  for key in res
    console.log "deleting " + key
    rclient.del(key, redis.print)
)

# Setup Express middleware.
app.use express.bodyParser()
app.use express.methodOverride()
app.use app.router
app.use express.static __dirname + '/public'

app.all '/chats', (req, res) ->
  # A group id needs to be set
  # TODO Check that this is the group the person has access to.
  unless req.param('gid')? then return

  # TODO figure out how to make this global, probably
  # create a middleware thingy.
  # This SO answer looks helpful - http://stackoverflow.com/questions/7067966/how-to-allow-cors-in-express-nodejs
  res.header("Access-Control-Allow-Origin",
    req.header('origin'))
  res.header("Access-Control-Allow-Headers", "X-Requested-With")
  res.header("X-Powered-By","nodejs")
  rclient.lrange('chats:' + req.param('gid'), 0, 100, (err, reply) ->
    chats = []
    for chat in reply
      chats.unshift(JSON.parse(chat))
    res.send chats
  )

app.post '/drupal', (req, res) ->
  exports[req.body.method](req.body.data)
  res.send 'ok'

exports.newUser = (data) ->
  rclient.hset('userkey:' + data.key, 'uid', data.uid, redis.print)
  rclient.hset('userkey:' + data.key, 'group', data.group, redis.print)
  io.sockets.emit 'chat', uid:data.uid, body: JSON.stringify(data) # Temp

io.sockets.on 'connection', (socket) ->

  socket.on 'chat', (data) ->
    socket.get 'key', (err, key) ->
      rclient.hgetall 'userkey:' + key, (err, res) ->
        io.sockets.in(res.group).emit 'chat',
          uid: res.uid, body: data.body
        # Save chats to Redis
        data.uid = res.uid
        rclient.lpush('chats:' + res.group, JSON.stringify(data))

  socket.on 'auth', (key) ->
    # Retrieve the user ID and group ID from Redis and
    # set locally in socket.io and send to the client.
    rclient.hgetall('userkey:' + key, (err, res) ->
      # No key in redis means user not authenticated by Drupal.
      unless res.group? and res.uid? then return
      socket.set('key', key)
      socket.join(res.group)
      socket.emit 'set group', parseInt(res.group)

      socket.emit 'set uid', parseInt(res.uid)

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
        io.sockets.in(res.group).emit 'leave', parseInt(res.uid)
        rclient.srem('connected:' + res.group, res.uid)
        rclient.del('userkey:' + key)

app.listen 3000
