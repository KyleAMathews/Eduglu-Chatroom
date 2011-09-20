require('zappa') ->
  at chat: ->
    io.sockets.emit 'chat', uid: 'blue', body: @body
