#= require ../variables
#= require jquery
#= require jquery_ujs
#= require js-routes
#= require vendor/jquery.cookie
#= require twitter/bootstrap/bootstrap-tooltip
#= require_tree ../libraries
#= require vendor/antiscroll
#= require vendor/debounce.jquery
#= require sugar

window.gmap = null

window.default_options =

window.load_google_maps = ->
  script = document.createElement("script")
  script.type = "text/javascript"
  script.src = "http://maps.googleapis.com/maps/api/js?key=#{window.google_maps_key}&sensor=false&callback=google_maps_loaded"
  document.body.appendChild(script)

window.google_maps_loaded = ->
  window.is_google_maps_loaded = true
  do window.google_maps_loaded_callback if window.google_maps_loaded_callback

window.ensuring_google_maps_loaded = (callback) ->
  if window.is_google_maps_loaded
    do callback
  else
    window.google_maps_loaded_callback = callback
    do window.load_google_maps

one_time = (callback) ->
  unless window.did_it
    window.did_it = true
    do callback

extend_google_maps = ->
  google.maps.Map::markers = []
  google.maps.Map::overlays = []
  google.maps.Map::getMarkers = -> @markers
  google.maps.Map::getOverlays = -> @overlays

  google.maps.Map::clearMarkers = ->
    marker.setMap null for marker in @markers
    @markers = []

  google.maps.Map::clearOverlays = ->
    overlay.setMap null for overlay in @overlays
    @overlays = []

  google.maps.Marker::_setMap = google.maps.Marker::setMap
  google.maps.Marker::setMap = (map) ->
    map.markers[map.markers.length] = this  if map
    @_setMap map

  google.maps.OverlayView::_setMap = google.maps.OverlayView::setMap
  google.maps.OverlayView::setMap = (map) ->
    map.overlays[map.overlays.length] = this if map
    @_setMap map

  google.maps.LatLngBounds.prototype.toString = ->
    this.toUrlValue().split(',').inGroupsOf(2).map((e) -> e.join(',')).join(';')

construct_relic_marker = ->
  class google.maps.RelicMarker extends google.maps.OverlayView
    constructor: (@latlng, @number, @map, @click) ->
      this.setMap(map)

    draw: ->
      image_url = gmap_circles[@number.toString().length - 1]
      image_size = [55, 59, 75, 85, 105][@number.toString().length - 1]
      font_size = [14, 14, 17, 17, 17][@number.toString().length - 1]

      # cache drawn image
      @div ||= do =>
        marker = $("<div>#{@number}</div>").css
          position: "absolute"
          cursor: "pointer"
          textAlign: 'center'
          height: image_size
          width: image_size
          lineHeight: "#{image_size}px"
          fontWeight: "800"
          fontSize: font_size
          color: "#507283"
          backgroundImage: "url(#{image_url})"
          zIndex: 10000

        $(@getPanes().overlayImage).append(marker)

        google.maps.event.addDomListener marker[0], 'click', (e) =>
          @click() if @click?
          false

        marker

      if point = @getProjection().fromLatLngToDivPixel(@latlng)
        @div.css(left: point.x - image_size/2, top: point.y - image_size/2)

    remove: ->
      @div.remove() if @div

FOUND_ROUTE = null
ON_IDLE_EVENT = null

waitForMapMovement = (callback) ->
  ON_IDLE_EVENT = callback

initialize_gmap = ->
  if !window.gmap
    window.gmap = new google.maps.Map document.getElementById('map_canvas'),
      mapTypeId: google.maps.MapTypeId.HYBRID
      
    gmap.directions = new google.maps.DirectionsService
    gmap.directions.renderer = new google.maps.DirectionsRenderer
      map: gmap

    gmap.getLatLngBounds = ->
      bounds = gmap.getBounds()
      if bounds
        north_east = bounds.getNorthEast()
        south_west = bounds.getSouthWest()
        bounds = new google.maps.LatLngBounds(
          new google.maps.LatLng(north_east.lat(), south_west.lng())
          new google.maps.LatLng(south_west.lat(), north_east.lng())
        )
        
    # prevent first on idle event
    ON_IDLE_EVENT = ->
    fitting_bounds = false

    old_set_zoom = google.maps.Map.prototype.setZoom
    google.maps.Map.prototype.setZoom = (zoom) ->
      zoom += 1 if fitting_bounds
      old_set_zoom.call(this, zoom)
      fitting_bounds = false

    old_fit_bounds = google.maps.Map.prototype.fitBounds
    google.maps.Map.prototype.fitBounds = (bounds) ->
      fitting_bounds = true
      old_fit_bounds.call(this, bounds)

    idle = $.throttle ->
      if ON_IDLE_EVENT?
        idle_event = ON_IDLE_EVENT
        ON_IDLE_EVENT = null
        do idle_event
      else
        $('#search_bounding_box').val(gmap.getLatLngBounds().toString())
        searchRelics()
    , 3000

    google.maps.event.addListener gmap, 'idle', idle

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
      new google.maps.RelicMarker latlng, @facet_count, gmap, =>
        $('#search_location').val("#{@type}:#{@id}")
        $('#search_bounding_box').val("")
        $('#new_search').submit()
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

drawRoute = (route, callback) ->

searchRoute = (search_params, callback) ->
  return callback(FOUND_ROUTE) if FOUND_ROUTE
  
  request =
    origin: search_params.start
    destination: search_params.end
    travelMode: google.maps.TravelMode.WALKING

  gmap.directions.route request, (result, status) ->
    if status == google.maps.DirectionsStatus.OK
      FOUND_ROUTE = route = result.routes[0]
      route.path = route.overview_path.map (o) ->
        latitude: o.Ya, longitude: o.Za
       
      gmap.directions.renderer.setDirections(result)
      waitForMapMovement -> callback(route)
    else
      alert('Nie znaleziono trasy! Spróbuj ponownie.')


searchRelics = (callback) ->
  search_params = $('#new_search').serializeObject().search
  search_params.api_key = "oz"
  search_params.per_page = 1000

  window.parent.postMessage(JSON.stringify(
    event: "on_params_changed", params: search_params
  ), "*")
  

  searchRoute search_params, (route) ->
    console.log(gmap.getLatLngBounds().toString())
    search_params.bounding_box = gmap.getLatLngBounds().toString()
    $.ajax
      url: Routes.api_v1_relics_path(search_params)
      dataType: 'json'
      success: (result) ->
        process(search_params, result.clusters, result.relics, route.path)
      error: ->
        alert('Nastąpił błąd podczas wyszukiwania zabytków.')

  false

jQuery ->

  $('a.tooltip').tooltip()
  $('#new_search').submit(searchRelics)

  window.ensuring_google_maps_loaded ->
    do extend_google_maps
    do construct_relic_marker
    do initialize_gmap
