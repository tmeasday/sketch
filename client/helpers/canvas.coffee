MAX_PATH_LENGTH = 100
class SketchCanvas
  constructor: (@canvas) ->
    @ctx = @canvas.getContext("2d")
    
    # prepare the background for the canvas
    @image = new Image
    @image.onload = => @drawBackground()
    @image.src = '/img/canvas-bg.jpg'
    
    @brushes = for i in [0...N_BRUSHES]
      brush = new Image
      num = i + 1
      num = '0' + num if num < 10
      brush.src = "/img/brushes/round-#{num}.png"
      brush
    
    # set some preferences for our line drawing.
    @ctx.fillStyle = "solid"
    @ctx.lineWidth = 5
    @ctx.lineCap = "round"
    
  
  drawBackground: ->
    @ctx.drawImage(@image, 0, 0)
  
  # XXX: should the event listening stuff be refactored out of here?
  listen: ->
    $(@canvas)
      .on('mousedown touchstart', (e) => @start(e))
      .on('mousemove touchmove', (e) => @drag(e))
      .on('mouseup touchend touchcancel touchleave', (e) => @end(e))
  
  start: (e) ->
    e.preventDefault()
    $canvas = $(@canvas)
    @offset = $canvas.offset()
    
    @path = new Path({brushNumber: Session.get('currentBrushNumber')})
    @path.addPointFromEvent(e, @offset)
  
  drag: (e) ->
    e.preventDefault()
    # if we are dragging
    if @path
      # reset the path if it gets too long
      length = @path.attributes.points.length
      if length > MAX_PATH_LENGTH
        last_point = @path.attributes.points[length - 1]
        @path = new Path({brushNumber: Session.get('currentBrushNumber'), points: [last_point]})
      
      @path.addPointFromEvent(e, @offset) 
      iteracted()
  
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
    @drawPath({attributes: {brushNumber: 0, points: [{x:10, y:10}, {x: 100; y:100}]}})
  
  drawLine: (start, end, brush) ->
    # 2-d length
    length = (w,h) -> Math.sqrt(w*w + h*h)
    
    x_diff = end.x - start.x
    y_diff = end.y - start.y
    
    # count the number of steps we need
    steps = 2.0 * Math.ceil(length(x_diff, y_diff) / Math.min(brush.width, brush.height))
    
    # abort if weirdness
    return unless steps
    
    x_step = x_diff / steps
    y_step = y_diff / steps
        
    x = start.x - brush.width / 2
    y = start.y - brush.height / 2
    for i in [1..steps]
      @ctx.drawImage(brush, x, y)
      x += x_step
      y += y_step
      
  drawPoints: (points, brush) ->
    lastPoint = points.shift()
    for point in points
      @drawLine(lastPoint, point, brush)
      lastPoint = point
  
  drawPath: (path) ->
    @drawPoints path.attributes.points.slice(0), @brushes[path.attributes.brushNumber]
  
  # assumes that oldPath is already drawn
  updatePath: (newPath, oldPath) ->
    first = Math.max(oldPath.attributes.points.length - 1, 0)
    @drawPoints newPath.attributes.points.slice(first), @brushes[newPath.attributes.brushNumber]
