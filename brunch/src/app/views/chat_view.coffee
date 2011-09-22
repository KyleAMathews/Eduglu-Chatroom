chatTemplate = require('templates/chat')

class exports.ChatView extends Backbone.View
  className: 'chat'
  tagName: 'li'

  render: =>
    user = app.collections.users.get(@model.get("uid"))

    # Shorten the person's name.
    split = user.get("name").split(' ')
    newName = split.slice(0,1)[0].split('')[0] # Grab the first letter of the first name.
    newName += ". " + split.pop() # Grab the last name.
    user.set( shortname: newName)

    # Remove the sub-second accuracy from our date as humaneDates doesn't like it.
    date = @model.get('date')
    split = date.split('.')
    @model.set(date: split[0] + 'Z')
    $(@el).html chatTemplate( model: @model, user: user )
    @$('.humaneDate').humaneDates()
    @
