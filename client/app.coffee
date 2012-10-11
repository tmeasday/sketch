Meteor.autosubscribe ->
  Meteor.subscribe 'paths', Session.get('pathsSince')

canvasDataURL = ->
  canvas = $('canvas').get(0)
  canvas.toDataURL('image/png') if canvas

Template.canvas.rendered = ->
  unless @canvas
    @canvas = new SketchCanvas(@find('canvas'))
    @handle = Paths.find().observe
      added: (path) => @canvas.drawPath(path)
      # draw over the top, no big deal
      changed: (newPath, index, oldPath) => 
        @canvas.updatePath(newPath, oldPath)
      # we only ever delete all the paths at once, so this is fine.
      removed: (path) => @canvas.clear()
    
    Meteor.defer =>
      @canvas.listen()

Template.canvas.destroyed = ->
  this.handle.stop()

Template.controls.preserve ['.controls']
Template.controls.hidden = -> 
  'hidden' if Session.get('saving')

Template.controls.events
  'click .clear-btn': ->
    Session.set('pathsSince', new Date().getTime())
  'click .save-btn': ->
    Session.set('saving', true)
  'click .new-brush-btn': ->
    oldBrush = Session.get('currentBrushNumber')
    newBrush = randomBrushNumber()
    # just make sure we don't pull the same brush again
    newBrush = randomBrushNumber() while (newBrush == oldBrush)
    Session.set('currentBrushNumber', newBrush)

Template.saveOverlay.preserve(['.save-wrap'])
Template.saveOverlay.helpers
  saveOpen: -> 'open' if Session.get('saving')
  canvasDataURL: -> canvasDataURL()

Template.saveOverlay.events
  'click .close-info': -> Session.set('saving', false)
  'submit': (e, template) ->
    e.preventDefault()
    
    to = template.find('[name=fullname]').value
    email = template.find('[name=email]').value
    dataURL = canvasDataURL()
    
    Meteor.call('emailPicture', to, email, dataURL)
    Session.set('saving', false)

Meteor.startup ->
  Session.set('currentBrushNumber', randomBrushNumber())
  Session.set('pathsSince', new Date().getTime())