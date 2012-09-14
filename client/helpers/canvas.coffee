class SketchCanvas
  constructor: (@canvas) ->
    @ctx = @canvas.getContext("2d")
      
    # set some preferences for our line drawing.
    @ctx.fillStyle = "solid"
    @ctx.lineWidth = 5
    @ctx.lineCap = "round"
    
  clear: ->
    # Store the current transformation matrix
    @ctx.save();

    # Use the identity matrix while clearing the canvas
    @ctx.setTransform(1, 0, 0, 1, 0, 0);
    @ctx.clearRect(0, 0, @canvas.width, @canvas.height);

    # Restore the transform
    @ctx.restore();
  
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
    