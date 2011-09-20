express = require('express')
app = express.createServer()
io = require('socket.io').listen(app)
redis = require 'redis'
rclient = redis.createClient()

io.configure(->
  io.set('origin', 'http://localhost')
)
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
      chats.push(JSON.parse(chat))
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
  res.send( id: 1, name: "Kyle Mathews", pic: "https://island.byu.edu/files/imagecache/20x20_crop/pictures/picture-3.jpg" )

app.post '/drupal', (req, res) ->
  exports[req.body.method](req.body.data)
  res.send 'ok'

exports.newUser = (data) ->
  console.log data

io.sockets.on 'connection', (socket) ->
  socket.emit 'welcome', time: new Date()

  socket.on 'chat', (data) ->
    console.log data
    io.sockets.emit 'chat',
      uid: data.uid, body: data.body
    # Save chats to Redis
    rclient.lpush('chats', JSON.stringify(data))

app.listen 3000
