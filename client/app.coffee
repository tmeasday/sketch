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

Meteor.startup ->
  # ensure we start a new path
  Session.set('currentPathId', null)
  
  cvs = app.canvas.init(document.getElementsByTagName('article')[0])
  
  $(cvs).on 'drag', (e) ->
    path = currentPath() || new Path()
    
    path.addPoint({x: e.offsetX, y: e.offsetY})
    Session.set('currentPathId', path.id)
    