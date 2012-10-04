N_BRUSHES = 7


randomColor = ->
  colors = ['red', 'green', 'blue', 'yellow', 'pink', 'black', 'purple',
    'orange', 'magenta', 'grey', 'maroon']
  colors[Math.floor(Math.random() * colors.length)]

randomBrushNumber = ->
  Math.floor(Math.random() * N_BRUSHES)
