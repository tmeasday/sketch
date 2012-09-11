class SketchCanvas
  init: (@element) ->
    @canvas = document.createElement 'canvas'
    @canvas.height = 400
    @canvas.width = 800
    @element.appendChild(@element)
  
    @ctx = App.canvas.getContext("2d")
  
    # set some preferences for our line drawing.
    @ctx.fillStyle = "solid"
    @ctx.strokeStyle = "#ECD018"
    @ctx.lineWidth = 5
    @ctx.lineCap = "round"
  
  drawPath: (path) ->
    points = path.points.slice(0)
    
    start = points.unshift()
    @ctx.beginPath()
    @ctx.moveTo(start.x, start.y)
    
    for point in path.points
      @ctx.lineTo(x,y)
      @ctx.stroke()
    
    @ctx.closePath()
    