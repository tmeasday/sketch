Meteor.publish 'paths', (since) ->
  Paths.find({createdAt: {$gt: since}});
