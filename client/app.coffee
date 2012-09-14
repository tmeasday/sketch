Meteor.autosubscribe ->
  Meteor.subscribe 'paths', Session.get('pathsSince')

Paths.find().observe
  added: (path) -> 
    app.canvas.drawPath(path)
  changed: (path) ->
    app.canvas.drawPath(path)

app = {}
app.canvas = new SketchCanvas

currentPath = ->
  pathId = Session.get('currentPathId')
  Paths.findOne(pathId) if pathId

Template.buttons.color = -> 
  Session.get('currentColor')

Template.buttons.events
  'click .reset': ->
    Session.set('pathsSince', new Date().getTime())

Meteor.startup ->
  Session.set('currentColor', randomColor())
  Session.set('pathsSince', new Date().getTime())
  
  # ensure we start a new path
  Session.set('currentPathId', null)
  
  cvs = app.canvas.init(document.getElementsByTagName('article')[0])
  
  $(cvs).on('dragstart', (e) -> 
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