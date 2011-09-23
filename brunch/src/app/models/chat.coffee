class exports.Chat extends Backbone.Model
  defaults:
    uid: 1
    body: ""
    date: ""

  initialize: ->
    # Remove the sub-second accuracy from our date as humaneDates doesn't like it.
    date = @get('date')
    split = date.split('.')
    @set(date: split[0] + 'Z')

    # Make links clickable and make *bold* bold and **italics** italics.
    body = @get('body')
    html = body.replace(/\b((?:[a-z][\w-]+:(?:\/{1,3}|[a-z0-9%])|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}\/)(?:[^\s()<>]+|\((?:[^\s()<>]+|(\(?:[^\s()<>]+\)))*\))+(?:\((?:[^\s()<>]+|(?:\(?:[^\s()<>]+\)))*\)|[^\s`!()\[\]{};:'".,<>?«»“”‘’]))/i, '<a href="$1">$1</a>')
    html = html.replace(/\*\*(.+)\*\*/, '<em>$1</em>')
    html = html.replace(/\*(.+)\*/, '<strong>$1</strong>')
    @set( html: html )
