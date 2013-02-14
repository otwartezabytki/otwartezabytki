#= require ../variables
#= require jquery
#= require jquery_ujs
#= require js-routes
#= require vendor/jquery.cookie
#= require twitter/bootstrap/bootstrap-tooltip
#= require_tree ../libraries
#= require vendor/antiscroll
#= require sugar

window.gmap = null
FOUND_ROUTE = null

show_content_window = (marker, content) ->
  if marker.info_window
    marker.info_window.close(gmap, marker)
    marker.info_window = null
  else
    if gmap.info_window
      gmap.info_window.close(gmap, gmap.info_window.marker)
      gmap.info_window.marker.info_window = null
      gmap.info_window = null

    gmap.info_window = marker.info_window = new google.maps.InfoWindow
      content: content

    marker.info_window.marker = marker

    marker.info_window.open(gmap, marker)

render_relic_info = (relic) ->
  photo = if relic.main_photo then "<div class='photo-wrapper'><img src='#{relic.main_photo.file.midi.url}' width='50' height='50'></div>" else ""
  link = "<a href='#{Routes.relic_path(relic.id)}' target='_blank'>więcej »</a>"
  "<div class='relic-info'>#{photo}<div class='relic-info-content'><h3>#{relic.identification}</h3><div>#{relic.street}</div><div>#{link}</div></div></div>"


renderResults = (search_groups, search_results) ->
  gmap.clearMarkers()
  gmap.clearOverlays()
 
  $.each search_groups, ->
    latlng = new google.maps.LatLng(@latitude, @longitude)

    if @facet_count > 1
      marker = new google.maps.RelicMarker latlng, @facet_count, =>
        $('#search_location').val("#{@type}:#{@id}")
        $('#search_bounding_box').val("")
        $('#new_search').submit()

      marker.setMap(gmap)
    else
      marker = new google.maps.Marker
        map: gmap
        icon: gmap_marker
        position: latlng
        clickable: true

      load_relic_info = (callback) =>
        search_params
        search_params.api_key = "oz"
        search_params.location = "#{@type}:#{@id}"
        $.get Routes.api_v1_relics_path(search_params), (result) ->
          callback(render_relic_info(result.relics[0]))
        , "json"

      google.maps.event.addListener marker, 'click', ->
        load_relic_info (content) ->
          show_content_window(marker, content)

  markers = []
  $.each search_results, ->
    latlng = new google.maps.LatLng(@latitude, @longitude)

    marker = new google.maps.Marker
      map: gmap
      icon: gmap_marker
      position: latlng
      clickable: true

    markers[@id] = marker

    google.maps.event.addListener marker, 'click', =>
      content = render_relic_info(this)
      show_content_window(marker, content)

  $('a.point-relic').click ->
    google.maps.event.trigger(markers[$(this).data('id')], 'click')
    false


# Distance from a point to a line or segment.
#
# @param {number} x point's x coord
# @param {number} y point's y coord
# @param {number} x0 x coord of the line's A point
# @param {number} y0 y coord of the line's A point
# @param {number} x1 x coord of the line's B point
# @param {number} y1 y coord of the line's B point
# @param {boolean} overLine specifies if the distance should respect the limits
# of the segment (overLine = true) or if it should consider the segment as an
# infinite line (overLine = false), if false returns the distance from the point to
# the line, otherwise the distance from the point to the segment.
dotLineLength = (x, y, x0, y0, x1, y1, o) ->
  lineLength = (x, y, x0, y0) ->
    Math.sqrt (x -= x0) * x + (y -= y0) * y
  d = (x, y, x0, y0, x1, y1) ->
    unless x1 - x0
      return (
        x: x0
        y: y
      )
    else unless y1 - y0
      return (
        x: x
        y: y0
      )
    left = undefined
    tg = -1 / ((y1 - y0) / (x1 - x0))
    x: left = (x1 * (x * tg - y + y0) + x0 * (x * -tg + y - y1)) / (tg * (x1 - x0) + y0 - y1)
    y: tg * left - tg * x + y

  o = d(x, y, x0, y0, x1, y1)
  unless o.x >= Math.min(x0, x1) and o.x <= Math.max(x0, x1) and o.y >= Math.min(y0, y1) and o.y <= Math.max(y0, y1)
    l1 = lineLength(x, y, x0, y0)
    l2 = lineLength(x, y, x1, y1)
    (if l1 > l2 then l2 else l1)
  else
    a = y0 - y1
    b = x1 - x0
    c = x0 * y1 - y0 * x1
    Math.abs(a * x + b * y + c) / Math.sqrt(a * a + b * b)

distanceToLine = (point, begin, end) ->
 dotLineLength(
   point.latitude, point.longitude,
   begin.latitude, begin.longitude,
   end.latitude, end.longitude
 )

distanceInKm = (distance) ->
  R = 6371
  rad = distance.toRad()
  a = Math.sin(rad) * Math.sin(rad)
  c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
  d = R * c

distanceToPath = (point, path) ->
  distances = for i in [0...path.length - 1]
    distanceToLine(point, path[i], path[i + 1])

  distanceInKm(distances.min())
 
if typeof (Number::toRad) is "undefined"
  Number::toRad = -> this * Math.PI / 180

process = (params, groups, results, path) ->
  results = results.filter (result) ->
    distanceToPath(result, path) <= parseInt(params.radius, 10)

  groups = groups.filter (group) ->
    distanceToPath(group, path) <= parseInt(params.radius, 10)

  renderResults(groups, results)

# Serialize form to JSON
$.fn.serializeObject = ->

  json = {}
  push_counters = {}
  patterns =
    validate  : /^[a-zA-Z][a-zA-Z0-9_]*(?:\[(?:\d*|[a-zA-Z0-9_]+)\])*$/,
    key       : /[a-zA-Z0-9_]+|(?=\[\])/g,
    push      : /^$/,
    fixed     : /^\d+$/,
    named     : /^[a-zA-Z0-9_]+$/

  @build = (base, key, value) ->
    base[key] = value
    base

  @push_counter = (key) ->
    push_counters[key] = 0 if push_counters[key] is undefined
    push_counters[key]++

  $.each $(@).serializeArray(), (i, elem) =>
    return unless patterns.validate.test(elem.name)

    keys = elem.name.match patterns.key
    merge = elem.value
    reverse_key = elem.name

    while (k = keys.pop()) isnt undefined

      if patterns.push.test k 
        re = new RegExp("\\[#{k}\\]$")
        reverse_key = reverse_key.replace re, ''
        merge = @build [], @push_counter(reverse_key), merge

      else if patterns.fixed.test k 
        merge = @build [], k, merge

      else if patterns.named.test k
        merge = @build {}, k, merge

    json = $.extend true, json, merge

  return json

searchRoute = (search_params, callback) ->
  return callback(FOUND_ROUTE) if FOUND_ROUTE?

  request =
    origin: search_params.start + ", Polska"
    destination: search_params.end + ", Polska"
    travelMode: google.maps.TravelMode.WALKING
    region: 'pl'

  gmap.directions.route request, (result, status) ->
    if status == google.maps.DirectionsStatus.OK
      FOUND_ROUTE = route = result.routes[0]
      route.path = route.overview_path.map (o) ->
        latitude: o.Ya, longitude: o.Za

      gmap.directionsRenderer.setDirections(result)
      gmap.onNextMovement -> callback(route)
    else
      alert('Nie znaleziono trasy! Spróbuj ponownie.')

performSearch = (search_params, callback) ->
  search_params._method = 'get'
  $.ajax
    url: '/api/v1/relics'
    type: 'post'
    data: search_params
    dataType: 'json'
    success: (result) ->
      callback(result)
    error: ->
      alert('Nastąpił błąd podczas wyszukiwania zabytków.')

debouncedSearchRelics = jQuery.debounce ->
  search_params = $('#new_search').serializeObject().search
  search_params.api_key = "oz"
  search_params.per_page = 1000

  window.parent.postMessage(JSON.stringify(
    event: "on_params_changed", params: search_params
  ), "*")

  if search_params.start.length && search_params.end.length
    searchRoute search_params, (route) ->
      search_params.path = route.path.map((e) -> [e.latitude, e.longitude])
      performSearch search_params, (result) ->
        process(search_params, result.clusters, result.relics, route.path)
  else
    performSearch search_params, (result) ->
      renderResults(result.clusters, result.relics)

  false
, 3000

searchRelics = ->
  debouncedSearchRelics()
  false

jQuery ->
  $('a.tooltip').tooltip()
  $('#new_search').submit(searchRelics)
  $('#search_begin, #search_end').change(-> FOUND_ROUTE = null)
  gmaps.load google_maps_key, ->
    window.gmap = new google.maps.Map $('#map_canvas')[0],
      mapTypeId: google.maps.MapTypeId.HYBRID

    gmap.onMovement ->
      if bounds = gmap.getLatLngBounds()
        $('#search_bounding_box').val(bounds.toString())
        searchRelics()

     google.maps.event.addListener gmap.directionsRenderer,
       'directions_changed',
       searchRelics

    gmap.onNextMovement ->
    gmap.setCenter(new google.maps.LatLng(52, 20))
    gmap.setZoom(6)
    searchRelics()
