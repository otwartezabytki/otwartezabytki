#= require ../variables
#= require jquery
#= require jquery_ujs
#= require js-routes
#= require vendor/jquery.cookie
#= require twitter/bootstrap/bootstrap-tooltip
#= require vendor/antiscroll
#= require sugar
#= require_tree ../libraries
#= require gmaps/marker-clusterer
#= require gmaps/context-menu
#= require gmaps/extras

window.gmap = null
window.marker_clusterer = null
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

markers = []
overlays = []

clearMarkers = ->
  marker_clusterer.clearMarkers() if marker_clusterer
  gmap.clearOverlays()
  for marker in gmap.markers
    marker.setMap(null) unless marker.getDraggable()
  marker.setMap(null) for marker in markers
  markers = []
  overlays = []

renderResults = (search_groups, search_results) ->
  do clearMarkers
  $.each search_groups, ->
    latlng = new google.maps.LatLng(@latitude, @longitude)

    if @facet_count > 1
      overlay = new google.maps.RelicMarker latlng, @facet_count, =>
        southWest = new google.maps.LatLng(@bounding_box[0].lat, @bounding_box[0].lng)
        northEast = new google.maps.LatLng(@bounding_box[1].lat, @bounding_box[1].lng)
        bounds = new google.maps.LatLngBounds(southWest, northEast)
        gmap.fitBounds(bounds, true)
        $('#search_location').val("#{@type}:#{@id}")
        $('#search_bounding_box').val(bounds.toString()) unless FOUND_ROUTE?
        $('#new_search').submit()

      overlay.setMap(gmap)

      overlays.push(overlay)
    else
      marker = new google.maps.Marker
        map: gmap
        icon: gmap_marker
        position: latlng
        clickable: true
        optimized: false

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

  $.each search_results, ->
    latlng = new google.maps.LatLng(@latitude, @longitude)

    marker = new google.maps.Marker
      map: gmap
      icon: gmap_marker
      position: latlng
      clickable: true
      optimized: false

    markers.push marker

    google.maps.event.addListener marker, 'click', =>
      content = render_relic_info(this)
      show_content_window(marker, content)

  image_urls = gmap_circles
  image_sizes = [55, 59, 75, 85, 105]
  font_sizes = [14, 14, 17, 17, 17]

  styles = image_urls.map (image, index) ->
    url: image,
    textSize: font_sizes[index]
    width: image_sizes[index]
    height: image_sizes[index]
    textColor: '#507283'

  marker_clusterer.clearMarkers() if marker_clusterer?
  marker_clusterer = new MarkerClusterer gmap, markers,
    maxZoom: 10
    styles: styles

  $('a.point-relic').click ->
    google.maps.event.trigger(markers[$(this).data('id')], 'click')
    false

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

String.prototype.appendCountry = ->
  this + if this.match(/[0-9\.,]+/) then "" else ", Polska"

searchRoute = (search_params, callback) ->
  do clearMarkers
  return callback(FOUND_ROUTE) if FOUND_ROUTE?

  waypoints = $('#waypoints .waypoint')
    .filter ->
      not $(this).val().isBlank()
    .map ->
      location: $(this).val().appendCountry()

  request =
    origin: search_params.start.appendCountry()
    destination: search_params.end.appendCountry()
    travelMode: google.maps.TravelMode.WALKING
    region: 'pl'
    waypoints: waypoints

  gmap.directions.route request, (result, status) ->
    if status == google.maps.DirectionsStatus.OK
      route      = result.routes[0]
      distance   = $('#search_radius').val()
      route.path = route.overview_path.map (o) ->
        latitude: o.lat().toFixed(6), longitude: o.lng().toFixed(6)

      factory = new jsts.geom.GeometryFactory()

      coordinates = route.path.map (p) ->
        new jsts.geom.Coordinate p.latitude, p.longitude

      centerLat = route.bounds.getCenter().lat()
      centerLng = route.bounds.getCenter().lng()
      # in km
      degreeInKm = haversineDistance \
        Math.round(centerLat) - 0.5,
        centerLng,
        Math.round(centerLat) + 0.5,
        centerLng

      line_string = factory.createLineString coordinates
      buffer = line_string.buffer distance / degreeInKm

      paths = buffer.shell.points.map (p) ->
        new google.maps.LatLng p.x, p.y

      FOUND_ROUTE = polygon = paths.map (p) -> p.toUrlValue()

      gmap.directionsRenderer.setDirections(result)
      gmap.onNextMovement -> callback(polygon)
    else
      alert('Nie znaleziono trasy! Spróbuj ponownie.')

performSearch = (search_params, callback) ->
  search_params._method = 'get'
  $.ajax
    url: '/api/v1/relics/clusters'
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
  search_params.per_page = 100
  search_params.widget = 1

  window.parent.postMessage(JSON.stringify(
    event: "on_params_changed", params: search_params
  ), "*")

  if search_params.start.length && search_params.end.length
    searchRoute search_params, (polygon) ->
      search_params.polygon = polygon.join(';')
      $('#search_polygon').val(search_params.polygon)
      # search_params.path = route.path.map((e) -> "#{e.latitude},#{e.longitude}").join(";")
      # $('#search_path').val(search_params.path)

  performSearch search_params, (result) ->
    renderResults(result.clusters, result.relics)

  false
, 3000


haversineDistance = (lat1, lon1, lat2, lon2) ->
  R = 6371 # km
  dlat = (lat2 - lat1) * Math.PI / 180.0
  dlon = (lon2 - lon1) * Math.PI / 180.0
  lat1 = lat1 * Math.PI / 180.0
  lat2 = lat2 * Math.PI / 180.0
  a = Math.sin(dlat / 2) * Math.sin(dlat/2) +
      Math.sin(dlon / 2) * Math.sin(dlon/2) * Math.cos(lat1) * Math.cos(lat2)
  c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
  R * c

searchRelics = ->
  debouncedSearchRelics()
  false

jQuery ->
  $search = $('#new_search')

  $('a.tooltip').tooltip()
  $search.submit(searchRelics)

  $search.on 'params:changed', ->
    FOUND_ROUTE = null

  $('body').on 'change', '#search_start, #search_end, #search_radius, #waypoints .waypoint', ->
    $search.trigger 'params:changed'

  $('#waypoints a.add-place').on 'click', (e) ->
    e.preventDefault()
    count = $('#waypoints .waypoint').length
    markup = """
      <div class="string clearfix optional stringish" id="search_waypoints_#{count}_input">
        <div class="input">
          <input id="search_waypoints_#{count}" name="search[waypoints[]]" type="text" value="" class="waypoint">
          <span class="remove suffix">&times;</span>
        </div>
      </div>
      """
    $('#waypoints .search-input').append markup
    $('#waypoints .waypoint:last').trigger 'focus'

  $('body').on 'click', '#waypoints .remove', ->
    $(this).parents('.string').remove()
    $search.trigger 'params:changed'

  window.gmap = new google.maps.Map $('#map_canvas')[0],
    mapTypeId: google.maps.MapTypeId.HYBRID

  gmap.menu = new contextMenu(map: window.gmap)

  gmap.menu.addItem 'Start route here', (map, latlng) ->
    $('#search_start').val("#{latlng.lat().toFixed(6)},#{latlng.lng().toFixed(6)}")
    searchRelics()

  gmap.menu.addItem 'End route here', (map, latlng) ->
    $('#search_end').val("#{latlng.lat().toFixed(6)},#{latlng.lng().toFixed(6)}")
    searchRelics()

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
