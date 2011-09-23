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

    # Make links clickable and make *bold* bold and **italics** italics.
    body = @model.get('body')
    html = body.replace(/\b((?:[a-z][\w-]+:(?:\/{1,3}|[a-z0-9%])|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}\/)(?:[^\s()<>]+|\((?:[^\s()<>]+|(\(?:[^\s()<>]+\)))*\))+(?:\((?:[^\s()<>]+|(?:\(?:[^\s()<>]+\)))*\)|[^\s`!()\[\]{};:'".,<>?«»“”‘’]))/i, '<a href="$1">$1</a>')
    html = html.replace(/\*\*(.+)\*\*/, '<em>$1</em>')
    html = html.replace(/\*(.+)\*/, '<strong>$1</strong>')
    @model.set( html: html )

    $(@el).html chatTemplate( model: @model, user: user )
    @$('.humaneDate').humaneDates()
    @
