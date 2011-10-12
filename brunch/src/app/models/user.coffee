class exports.User extends Backbone.Model
  defaults:
    name: ""
    pic: ""
    connected: false

  initialize: ->
    # Shorten the person's name.
    split = @get("name").split(' ')
    # Some people only have one name so don't need shortened.
    if split.length > 1
      newName = split.slice(0,1)[0].split('')[0] # Grab the first letter of the first name.
      newName += ". " + split.pop() # Grab the last name.
      @set( shortname: newName)
    else
      @set( shortname: @get("name"))
