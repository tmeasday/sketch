class SketchCanvas
  constructor: (@canvas) ->
    @ctx = @canvas.getContext("2d")
    
    # prepare the background for the canvas
    @image = new Image
    @image.onload = => @drawBackground()
    @image.src = '/img/canvas-bg.jpg'
    
    # set some preferences for our line drawing.
    @ctx.fillStyle = "solid"
    @ctx.lineWidth = 5
    @ctx.lineCap = "round"
  
  drawBackground: ->
    @ctx.drawImage(@image, 0, 0)
  
  listen: ->
    $(@canvas)
      .on('mousedown touchstart', (e) => @start(e))
      .on('mousemove touchmove', (e) => @drag(e))
      .on('mouseup touchend touchcancel touchleave', (e) => @end(e))
  
  start: (e) ->
    e.preventDefault()
    $canvas = $(@canvas)
    @offset = $canvas.offset()
    
    @path = new Path({color: Session.get('currentColor')})
    @path.addPointFromEvent(e, @offset)
  
  drag: (e) ->
    e.preventDefault()
    # if we are dragging
    @path.addPointFromEvent(e, @offset) if @path
  
  end: (e) ->
    e.preventDefault()
    @stop()
  
  stop: ->
    @path = null
  
  clear: ->
    # Store the current transformation matrix
    @ctx.save()

    # Use the identity matrix while clearing the canvas
    @ctx.setTransform(1, 0, 0, 1, 0, 0)
    @ctx.clearRect(0, 0, @canvas.width, @canvas.height)
    @drawBackground()
    
    # Restore the transform
    @ctx.restore()
  
  drawBasicPath: -> 
    @drawPath({attributes: {color: 'red', points: [{x:10, y:10}, {x: 100; y:100}]}})
  
  drawPath: (path) ->
    @ctx.strokeStyle = path.attributes.color
    
    points = path.attributes.points.slice(0)
    
    start = points.unshift()
    @ctx.beginPath()
    @ctx.moveTo(start.x, start.y)
    
    for point in points
      @ctx.lineTo(point.x,point.y)
      @ctx.stroke()
    
    @ctx.closePath()
  
  # assumes that oldPath is already drawn
  updatePath: (newPath, oldPath) ->
    @ctx.strokeStyle = newPath.attributes.color
    
    first = Math.max(oldPath.attributes.points.length - 1, 0)
    points = newPath.attributes.points.slice(first)
    
    start = points.unshift()
    @ctx.beginPath()
    @ctx.moveTo(start.x, start.y)
    
    for point in points
      @ctx.lineTo(point.x,point.y)
      @ctx.stroke()
    
    @ctx.closePath()
  