Meteor.publish 'paths', ->
  # TODO -- only find the paths that have changed since X
  Paths.find({});

Paths.allow
  insert: (u, d) -> true
  update: (u, ds, f, m) -> true
  remove: (u, ds) -> true

Recordings.allow
  insert: (u, d) -> true

Meteor.accounts.onCreateUser (options, extra, user) ->
  user.color = randomColor()
  user
  