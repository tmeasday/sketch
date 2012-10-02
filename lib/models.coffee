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
  
  addPointFromEvent: (event, offset) ->
    event = event.originalEvent.touches[0] if event.originalEvent.touches
    
    @addPoint
      x: event.offsetX || event.pageX - offset.left
      y: event.offsetY || event.pageY - offset.top

Paths = Path._collection = new Meteor.Collection('paths', null, null, null, Path)
