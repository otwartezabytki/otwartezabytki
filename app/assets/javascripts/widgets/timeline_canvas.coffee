timeline = document.getElementById 'timeline_canvas'
context = timeline.getContext '2d'

settings =
  centuryStart: 10
  centuryEnd: 20

  minWidth: 400
  padding: 25

  axisColor: '#8399a4'
  axisAltColor: '#ddd'
  axisThickness: 4

  axisStepWidth: 1
  axisStepHeight: 6
  axisAltStepWidth: 1
  axisAltStepHeight: 10

  axisFontStyle: '10px Open Sans, sans-serif'

  pixelOffset: 0.5


timelineDrawLine = (x1, y1, x2, y2, width, color) ->
  context.beginPath()
  context.moveTo x1, y1
  context.lineTo x2, y2
  context.lineWidth = width
  context.strokeStyle = color
  context.stroke()

timelineDrawAxisText = (x, y, value) ->
  context.textBaseline = 'top'
  context.textAlign = 'center';
  context.font = settings.axisFontStyle
  context.fillStyle = settings.axisAltColor
  context.fillText value, x, y

timelineDrawAxis = (x1, x2, y) ->
  timelineDrawSteps x1, x2, y, 10
  timelineDrawLine x1, y, x2, y, settings.axisThickness, settings.axisColor

timelineDrawSteps = (x1, x2, y, n) ->
  scope = x2 - x1 - settings.axisStepWidth / 2
  step = scope / (n - 1)
  last = x2 - settings.pixelOffset

  coordinates = (i for i in [x1..scope] by step).map (coordinate) ->
    Math.round(coordinate) + settings.pixelOffset
  coordinates.push last

  j1 = y - settings.axisStepHeight
  j2 = y + settings.axisStepHeight
  k1 = y - settings.axisAltStepHeight
  k2 = y + settings.axisAltStepHeight

  for i in coordinates
    timelineDrawLine i, j1, i, j2, settings.axisStepWidth, settings.axisColor
    timelineDrawAxisText i, j2 + 5, 'XX w.'

    unless i is last
      h = Math.round(i + step / 2) + settings.pixelOffset
      timelineDrawLine h, k1, h, k2, settings.axisAltStepWidth, settings.axisAltColor

window.timelineDraw = ->
  # Update dimensions of the fluid canvas
  timeline.width = width = Math.max timeline.offsetWidth, settings.minWidth
  timeline.height = height = timeline.offsetHeight

  timelineDrawAxis settings.padding, width - settings.padding, height / 2

  timeline
