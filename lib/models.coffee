class Path extends Model
  constructor: (attrs) ->
    # not sure why I can't do this
    # super(attrs)
    Model.call(this, attrs)
    
  addPoint: (point) ->
    if @attributes.points
      @save({$push: {points: point}})
    else
      @update_attribute('points', [point])


Paths = Path._collection = new Meteor.Collection('paths', null, null, Path)