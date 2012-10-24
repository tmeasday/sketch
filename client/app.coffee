# redrawing timeout in seconds
REDRAW_TIMEOUT = 5 * 60

Meteor.autosubscribe ->
  Meteor.subscribe 'paths', Session.get('pathsSince')

canvasDataURL = ->
  canvas = $('canvas').get(0)
  canvas.toDataURL('image/png') if canvas

# someone just interacted with the app, reset the redraw timer
iteracted = ->
  handle = Session.get('redrawHandle')
  Meteor.clearTimeout(handle) if handle
  
  handle = Meteor.setTimeout(
    (-> document.location.reload()), 
    REDRAW_TIMEOUT * 1000
  )
  Session.set('redrawHandle', handle)

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
    iteracted()
    Session.set('pathsSince', new Date().getTime())
  'click .save-btn': ->
    iteracted()
    Session.set('saving', true)
  'click .new-brush-btn': ->
    iteracted()
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
  'click .close-info': -> 
    iteracted()
    Session.set('saving', false)
  'submit': (e, template) ->
    iteracted()
    e.preventDefault()
    
    to = template.find('[name=fullname]').value
    email = template.find('[name=email]').value
    dataURL = canvasDataURL()
    
    Meteor.call('emailPicture', to, email, dataURL)
    Session.set('saving', false)

Meteor.startup ->
  iteracted()
  Session.set('currentBrushNumber', randomBrushNumber())
  Session.set('pathsSince', new Date().getTime())