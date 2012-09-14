Meteor.autosubscribe ->
  Meteor.subscribe 'paths', Session.get('pathsSince')

currentPath = ->
  pathId = Session.get('currentPathId')
  Paths.findOne(pathId) if pathId

Template.canvas.rendered = ->
  canvas = new SketchCanvas(this.find('canvas'))
  Paths.find().observe
    added: (path) -> canvas.drawPath(path)
    # draw over the top, no big deal
    changed: (path) -> canvas.drawPath(path)
    # we only ever delete all the paths at once, so this is fine.
    removed: (path) -> canvas.clear()

Template.buttons.color = -> Session.get('currentColor')

Template.buttons.events
  'click .reset': ->
    Session.set('pathsSince', new Date().getTime())
  'click .color': ->
    Session.set('currentColor', randomColor())

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