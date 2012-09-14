Meteor.autosubscribe ->
  Meteor.subscribe 'paths', Session.get('pathsSince')

currentPath = ->
  pathId = Session.get('currentPathId')
  Paths.findOne(pathId) if pathId

# FIXME -- Think about this some more please
Template.canvas.preserve('canvas')
Template.canvas.rendered = ->
  console.log('rendered')
  this.canvas ||= new SketchCanvas(this.find('canvas'))
  this.canvas.clear()
  Paths.find().forEach (p) => this.canvas.drawPath(p)
# this is just to set up reactivity (FIXME)
Template.canvas.paths = -> 
  console.log(Paths.find().count())
  ''

Template.buttons.color = -> Session.get('currentColor')

Template.buttons.events
  'click .reset': ->
    Session.set('pathsSince', new Date().getTime())

Meteor.startup ->
  Session.set('currentColor', randomColor())
  Session.set('pathsSince', new Date().getTime())
  
  # ensure we start a new path
  Session.set('currentPathId', null)
  
  $('canvas').on('dragstart', (e) -> 
    path = new Path({color: Session.get('currentColor')})
    path.addPoint({x: e.offsetX, y: e.offsetY})
    Session.set('currentPathId', path.id)
    
  ).on('drag', (e) ->
    path = currentPath() || new Path({color: Session.get('currentColor')})
    
    path.addPoint({x: e.offsetX, y: e.offsetY})
    Session.set('currentPathId', path.id)
  ).on('dragend', (e) ->
    path = currentPath()
    if path
      path.addPoint({x: e.offsetX, y: e.offsetY})
    
    Session.set('currentPathId', null)
  )