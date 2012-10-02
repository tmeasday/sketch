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
    console.log "mailing to #{address}"
    # FIXME -- get emailing details
    Email.send
      from: 'tom@bindle.me'
      to: "#{to} <#{address}>"
      subject: 'Your Sketch'
      html: "<img src='#{dataURI}'></img>"