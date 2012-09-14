Meteor.subscribe 'paths'
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
  Meteor.user() && Meteor.user().color

Template.buttons.events
  'click .reset': ->
    Paths.find().forEach (p) -> p.destroy()

Meteor.startup ->
  # ensure we start a new path
  Session.set('currentPathId', null)
  
  cvs = app.canvas.init(document.getElementsByTagName('article')[0])
  
  Meteor.deps.await_once((-> not Meteor.user()), -> Meteor.loginAnonymously())
  
  $(cvs).on('dragstart', (e) -> 
    path = new Path({color: Meteor.user().color})
    path.addPoint({x: e.offsetX, y: e.offsetY})
    Session.set('currentPathId', path.id)
    
  ).on('drag', (e) ->
    path = currentPath() || new Path({color: Meteor.user().color})
    
    path.addPoint({x: e.offsetX, y: e.offsetY})
    Session.set('currentPathId', path.id)
  ).on('dragend', (e) ->
    path = currentPath()
    if path
      path.addPoint({x: e.offsetX, y: e.offsetY})
    
    Session.set('currentPathId', null)
  )