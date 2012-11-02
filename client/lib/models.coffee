class Path extends Model
  constructor: (attrs) ->
    # not sure why I can't do this
    # super(attrs)
    Model.call(this, attrs)
    
  points: ->
    Points.find({pathId: @id}).fetch()
  
  addPoint: (point) ->
    @save() unless @persisted()
    
    point = new Point(point)
    point.attributes.pathId = @id
    point.save();
  
  addPointFromEvent: (event, offset) ->
    event = event.originalEvent.touches[0] if event.originalEvent.touches
    
    @addPoint
      x: event.offsetX || event.pageX - offset.left
      y: event.offsetY || event.pageY - offset.top

Paths = Path._collection = new Meteor.Collection('paths', {ctor: Path})

class Point extends Model
  constructor: (attrs) -> 
    Model.call(this, attrs)
  
  path: ->
    Paths.findOne(@attributes.pathId)

Points = Point._collection = new Meteor.Collection('points', {ctor: Point})
