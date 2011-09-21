express = require('express')
app = express.createServer()
io = require('socket.io').listen(app)

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
  # TODO figure out how to make this global, probably
  # create a middleware thingy.
  # This SO answer looks helpful - http://stackoverflow.com/questions/7067966/how-to-allow-cors-in-express-nodejs
  res.header("Access-Control-Allow-Origin",
    req.header('origin'))
  res.header("Access-Control-Allow-Headers", "X-Requested-With")
  res.header("X-Powered-By","nodejs")
  rclient.lrange('chats', 0, 100, (err, reply) ->
    chats = []
    for chat in reply
      chats.unshift(JSON.parse(chat))
    res.send chats
  )

app.all '/users', (req, res) ->
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
    'SELECT u.uid, r.realname as name
    FROM og_uid o
    INNER JOIN realname r
    INNER JOIN users u
    WHERE o.uid = r.uid
    AND o.uid = u.uid
    AND o.nid = ?', [req.param('gid')]
    (err, results, fields) ->
      if err then throw err
      for result in results
        result.pic = 'https://island.byu.edu/files/imagecache/20x20_crop/pictures/picture-' + result.uid + '.jpg' #TODO generate URL in Drupal and store within node.js somewhere
        result.id = result.uid
        users.push result

      users.push id: 1, uid: 1, name: "Island Admin", pic: 'https://island.byu.edu/files/imagecache/20x20_crop/pictures/picture-1.jpg'
      res.send users
  )

app.post '/drupal', (req, res) ->
  exports[req.body.method](req.body.data)
  res.send 'ok'

exports.newUser = (data) ->
  io.sockets.emit 'chat', uid:1, body: JSON.stringify(data)

io.sockets.on 'connection', (socket) ->

  socket.on 'chat', (data) ->
    console.log data
    io.sockets.emit 'chat',
      uid: data.uid, body: data.body
    # Save chats to Redis
    rclient.lpush('chats', JSON.stringify(data))

  socket.on 'set uid', (uid) ->
    socket.set('uid', uid)
    io.sockets.emit 'join', uid

  socket.on 'disconnect', ->
    socket.get('uid', (err, uid) ->
      io.sockets.emit 'leave', uid
    )

app.listen 3000
