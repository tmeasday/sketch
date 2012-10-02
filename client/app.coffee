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
      changed: (path) => @canvas.drawPath(path)
      # we only ever delete all the paths at once, so this is fine.
      removed: (path) => @canvas.clear()
    
    Meteor.defer =>
      @canvas.listen()

Template.canvas.destroyed = ->
  this.handle.stop()

Template.controls.preserve ['.controls']
Template.controls.hidden = -> 
  if !Session.get('noIntro') or Session.get('saving')
    'hidden'

Template.controls.events
  'click .clear-btn': ->
    Session.set('pathsSince', new Date().getTime())
  'click .save-btn': ->
    Session.set('saving', true)

Template.introOverlay.preserve(['.info-wrap'])
Template.introOverlay.helpers
  introOpen: -> 'open' unless Session.get('noIntro')

Template.introOverlay.events
  'click': -> Session.set('noIntro', true)

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
  Session.set('currentColor', randomColor())
  Session.set('pathsSince', new Date().getTime())