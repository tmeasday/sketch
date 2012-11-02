listeners = []
paths = []
Meteor.publish 'paths', (since) ->
  listeners[@sub_id] = @
  @complete()
  @flush()
  
  @onStop =>
    delete listeners[@sub_id]


Meteor.methods
  # simulate collections that don't exist client side
  '/paths/insert': (path) ->
    paths[path._id] = path
    for id, listener of listeners
      listener.set('paths', path._id, path)
      listener.flush()
  
  '/paths/update': (id, update) ->
    path = paths[id]
    
    # just going to assume the update is a push to points
    path.points = path.points.concat(update.$push.points)
    
    for id, listener of listeners
      listener.set('paths', path._id, {points: path.points})
      listener.flush()
    
  getTime: ->
    return new Date().getTime()
  
  emailPicture: (to, address, dataURI) ->
    console.log "uploading to flickr"
    photoid = Meteor.postFlickr({tags: 'Drawing Surrealism'}, dataURI)
    
    console.log "retrieving flickr URL"
    result = Meteor.callFlickr method: 'flickr.photos.getSizes', photo_id: photoid
    source = result.content.match(/\<size.*label\="Medium 800".*source="([^"]+)"\.*/)[1]
    
    imageURL = "http://www.flickr.com/photos/#{process.env.FLICKR_USER}/#{photoid}"
    console.log "mailing #{imageURL} to #{address}"
    
    html = EMAIL_STR
    html = html.replace(/\$SITE_URL/g, process.env.ROOT_URL)
    html = html.replace(/\$SOURCE_URL/g, source)
    html = html.replace(/\$IMAGE_URL/g, imageURL)
      
    Email.send
      from: 'lacma-drawing@lacma.org'
      to: "#{to} <#{address}>"
      subject: 'Your Sketch'
      html: html