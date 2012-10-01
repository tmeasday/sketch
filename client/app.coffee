Meteor.autosubscribe ->
  Meteor.subscribe 'paths', Session.get('pathsSince')

currentPath = ->
  pathId = Session.get('currentPathId')
  Paths.findOne(pathId) if pathId

Template.canvas.rendered = ->
  unless this.canvas
    this.canvas = new SketchCanvas(this.find('canvas'))
    this.handle = Paths.find().observe
      added: (path) => this.canvas.drawPath(path)
      # draw over the top, no big deal
      changed: (path) => this.canvas.drawPath(path)
      # we only ever delete all the paths at once, so this is fine.
      removed: (path) => this.canvas.clear()

Template.canvas.destroyed = ->
  this.handle.stop()

Template.controls.color = -> Session.get('currentColor')

Template.controls.events
  'click .reset': ->
    Session.set('pathsSince', new Date().getTime())
  'click .color': ->
    Session.set('currentColor', randomColor())

Meteor.startup ->
  Session.set('currentColor', randomColor())
  Session.set('pathsSince', new Date().getTime())
  
  # ensure we start a new path
  Session.set('currentPathId', null)
  
  # XXX: make sure that the canvas offset never changes
  offset = $('canvas').offset()
  $('canvas').on('dragstart', (e) -> 
    path = new Path({color: Session.get('currentColor')})
    
    path.addPointFromEvent(e, offset)
    Session.set('currentPathId', path.id)
    
  ).on('drag', (e) ->
    path = currentPath() || new Path({color: Session.get('currentColor')})
    
    offset = $('canvas').offset()
    path.addPointFromEvent(e, offset)
    Session.set('currentPathId', path.id)
  ).on('dragend', (e) ->
    path = currentPath()
    if path
      path.addPointFromEvent(e, offset)
    
    Session.set('currentPathId', null)
  )