class SketchCanvas
  constructor: (@canvas) ->
    @ctx = @canvas.getContext("2d")
    
    # prepare the background for the canvas
    @image = new Image
    @image.onload = => @drawBackground()
    @image.src = '/img/canvas-bg.jpg'
    
    # FIXME -- this should be attached to the path and random
    @brush = new Image
    @brush.src = "/img/brushes/round-stoke-01-color-01.png"
    
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
  
  drawLine: (start, end) ->
    console.log('draw line')
    console.log(start)
    console.log(end)
    # 2-d length
    length = (w,h) -> Math.sqrt(w*w + h*h)
    
    x_diff = start.x - end.x
    y_diff = start.y - end.y
    
    # count the number of steps we need
    steps = Math.ceil(length(x_diff, y_diff) / length(@brush.width, @brush.height))
    console.log(steps)
    
    # abort if weirdness
    return unless steps
    
    x_step = x_diff / steps
    y_step = y_diff / steps
        
    x = start.x - @brush.width / 2
    y = start.y - @brush.height / 2
    for i in [1..steps]
      console.log i
      console.log x,y
      @ctx.drawImage(@brush, x, y)
      x += x_step
      y += y_step
      
  drawPoints: (points) ->
    lastPoint = points.shift()
    for point in points
      @drawLine(lastPoint, point)
      lastPoint = point
  
  drawPath: (path) ->
    @drawPoints path.attributes.points.slice(0)
  
  # assumes that oldPath is already drawn
  updatePath: (newPath, oldPath) ->
    first = Math.max(oldPath.attributes.points.length - 1, 0)
    @drawPoints newPath.attributes.points.slice(first)
