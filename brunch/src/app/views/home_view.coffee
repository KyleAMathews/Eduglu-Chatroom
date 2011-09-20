homeTemplate = require('templates/home')

class exports.HomeView extends Backbone.View
  id: 'home-view'

  render: ->
    $(@el).html homeTemplate()
    $(@el).append app.views.chatsView.render().el
    @
