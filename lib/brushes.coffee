randomColor = ->
  colors = ['red', 'green', 'blue', 'yellow', 'pink', 'black', 'purple',
    'orange', 'magenta', 'grey', 'maroon']
  colors[Math.floor(Math.random() * colors.length)]
  
randomBrush = ->
  num = Math.ceil(Math.random() * 7)
  "/img/brushes/round-stroke-0#{num}-color-01.png"