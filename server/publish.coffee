Meteor.publish 'paths', (since) ->
  Paths.find({createdAt: {$gt: since}});

Paths.allow
  insert: (u, d) -> 
    d.createdAt = new Date().getTime();
    true
  update: (u, ds, f, m) -> 
    # a little hack, don't allow us to set createdAt
    if m.$set and m.$set.createdAt 
      delete m.$set.createdAt 
    true
  remove: (u, ds) -> true


Meteor.methods
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