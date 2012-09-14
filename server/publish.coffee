Meteor.publish 'paths', (since) ->
  Paths.find({createdAt: {$gt: since}});

Paths.allow
  insert: (u, d) -> 
    console.log(d)
    d.createdAt = new Date().getTime();
    console.log(d)
    true
  update: (u, ds, f, m) -> true
  remove: (u, ds) -> true

Recordings.allow
  insert: (u, d) -> true