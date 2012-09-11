Meteor.publish('paths', function() {
  // TODO -- only find the paths that have changed since X
  return Paths.find({});
});

