Meteor.publish 'paths', ->
  # TODO -- only find the paths that have changed since X
  Paths.find({});

