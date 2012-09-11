Meteor.subscribe 'paths'
Paths.find().observe
  changed: (path) ->
    app.canvas.drawPath(path)

app = {}
app.canvas = new SketchCanvas

Meteor.startup ->
  # ensure we start a new path
  Session.set('currentPathId', null)
  
  cvs = app.canvas.init(document.getElementsByTagName('article')[0])
  
  $(cvs).on 'drag', (e) ->
    
    # todo -> create models
    pathId = Session.get('currentPathId')
    pathId ||= Paths.insert({})
    Session.set('currentPathId', pathId)
    
    point = {x: e.offsetX, y: e.offsetY}
    
    Paths.update(pathId, {$push: {points: point}})
    