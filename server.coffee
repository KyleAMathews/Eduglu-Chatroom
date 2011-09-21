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

app.all '/users', (req, res) ->
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

  # Query Drupal for info on people in this group.
  users = []
  myclient.query(
    'SELECT u.uid, u.picture as pic, r.realname as name
    FROM og_uid o
    INNER JOIN realname r
    INNER JOIN users u
    WHERE o.uid = r.uid
    AND o.uid = u.uid
    AND o.nid = ?', [req.param('gid')]
    (err, results, fields) ->
      if err then throw err
      for result in results
        if result.picture?
          result.pic = 'https://island.byu.edu/files/imagecache/20x20_crop/pictures/picture-' + result.uid + '.jpg'
        else
          # Use the default picture.
          result.pic = "https://island.byu.edu/files/imagecache/25x25_crop/sites/all/themes/dewey/images/default_user_avatar.png"
        result.id = result.uid
        users.push result

      users.push id: 1, uid: 1, name: "Island Admin", pic: 'https://island.byu.edu/files/imagecache/20x20_crop/pictures/picture-1.jpg'
      res.send users
  )

app.post '/drupal', (req, res) ->
  exports[req.body.method](req.body.data)
  res.send 'ok'

exports.newUser = (data) ->
  rclient.hset(data.key, 'uid', data.uid, redis.print)
  rclient.hset(data.key, 'group', data.group, redis.print)
  io.sockets.emit 'chat', uid:data.uid, body: JSON.stringify(data) # Temp

io.sockets.on 'connection', (socket) ->

  socket.on 'chat', (data) ->
    socket.get 'key', (err, key) ->
      rclient.hgetall key, (err, res) ->
        io.sockets.in(res.group).emit 'chat',
          uid: res.uid, body: data.body
        # Save chats to Redis
        data.uid = res.uid
        rclient.lpush('chats:' + res.group, JSON.stringify(data))

  socket.on 'auth', (key) ->
    # Retrieve the user ID and group ID from Redis and
    # set locally in socket.io and send to the client.
    rclient.hgetall(key, (err, res) ->
      # No key in redis means user not authenticated by Drupal.
      unless res.group? and res.uid? then return
      socket.set('key', key)
      console.log res
      socket.join(res.group)
      socket.emit 'set group', parseInt(res.group)

      socket.emit 'set uid', parseInt(res.uid)
      io.sockets.in(res.group).emit 'join', parseInt(res.uid)
    )

  socket.on 'disconnect', ->
    socket.get 'key', (err, key) ->
      rclient.hgetall key, (err, res) ->
        io.sockets.in(res.group).emit 'leave', parseInt(res.uid)
        rclient.del(key)

app.listen 3000
