# Meteor.publish 'paths', (since) ->
#   pointHandles = {}
#   publishPath = (pathId) => 
#     pointHandles[pathId] = Points.find({pathId: pathId}).observe
#       added: (obj) =>
#         obj = obj._meteorRawData()
#         @set('points', obj._id, obj)
#         @flush()
#       
#       # these two should never happen
#       changed: (obj) =>
#         obj = obj._meteorRawData()
#         @set('points', obj._id, obj)
#         @flush()
#       
#       removed: (old_obj) =>
#         old_obj = old_obj._meteorRawData()
#         @unset('points', old_obj._id, _.keys(old_obj))
#         @flush()
#       
#   
#   pathHandle = Paths.find({createdAt: {$gt: since}}).observe
#     added: (obj) =>
#       obj = obj._meteorRawData()
#       @set('paths', obj._id, obj)
#       @flush()
#       publishPath(obj._id)
#     
#     # in general this should be smarter, but shouldn't happen much
#     changed: (obj) =>
#       obj = obj._meteorRawData()
#       @set('paths', obj._id, obj)
#       @flush()
#     
#     # this should never happen, but just in case
#     removed: (old_obj) =>
#       old_obj = old_obj._meteorRawData()
#       pointHandles[old_obj._id].stop()
#       @unset('paths', old_obj._id, _.keys(old_obj))
#       @flush()
#   
#   @complete()
#   @flush()
#   
#   @onStop =>
#     handle.stop() for handle in pointHandles
#     pathHandle.stop()
# 
# Paths.allow
#   insert: (u, d) -> 
#     d.createdAt = new Date().getTime();
#     true
#   update: (u, ds, f, m) -> 
#     # a little hack, don't allow us to set createdAt
#     if m.$set and m.$set.createdAt 
#       delete m.$set.createdAt 
#     true
#   remove: (u, ds) -> true
# 
# Points.allow
#   insert: (u, d) -> true

listeners = []
Meteor.publish 'paths', (since) ->
  listeners[@sub_id] = @
  @complete()
  @flush()
  
  @onStop =>
    delete listeners[@sub_id]
  


Meteor.methods
  # simulate collections that don't exist client side
  '/paths/insert': (path) ->
    for id, listener of listeners
      listener.set('paths', path._id, path)
      listener.flush()
    
  '/points/insert': (point) ->
    for id, listener of listeners
      listener.set('points', point._id, point)
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