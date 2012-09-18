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

Template.controls.recording = -> Recorder.recording()

Template.controls.events
  'click .reset': ->
    Session.set('pathsSince', new Date().getTime())
  'click .color': ->
    Session.set('currentColor', randomColor())
  'click .record': ->
    Recorder.start('Paths')
  'click .save': ->
    name = $('[name=saveName]').val()
    if name
      Recorder.save(name)
    else
      alert('Please provide a name for the recording')
  'click .cancel': ->
    Recorder.cancel()

Template.recordings.recordings = -> Recordings.find()
Template.recordings.events
  'click .run': ->
    Recorder.replay(this.name)

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