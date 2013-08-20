#= require gmaps/marker-clusterer
#= require gmaps/context-menu
#= require gmaps/extras

window.gmap = null
window.marker_clusterer = null
ROUTE = null
POLYGON = null

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
        $('#search_bounding_box').val(bounds.toString()) unless ROUTE?
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

getTravelMode = (type) ->
  switch type
    when 'bicycling'
      google.maps.TravelMode.BICYCLING
    when 'driving'
      google.maps.TravelMode.DRIVING
    else
      google.maps.TravelMode.WALKING

routeToPolygon = (route, distance) ->
  return POLYGON if POLYGON?

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

  POLYGON = paths.map (p) -> p.toUrlValue()

getWaypoints = ->
  $('#waypoints .waypoint')
    .filter ->
      not $(this).val().isBlank()
    .map ->
      $(this).val().appendCountry()
    .get()

searchRoute = (search_params, callback) ->
  do clearMarkers
  return callback(routeToPolygon(ROUTE, search_params.radius)) if ROUTE?

  origin      = search_params.waypoints.first()
  destination = search_params.waypoints.last()
  waypoints   = search_params.waypoints.slice(1, -1).map (wp) -> location: wp

  request =
    origin: origin
    destination: destination
    travelMode: getTravelMode search_params.route_type
    region: 'pl'
    waypoints: waypoints

  gmap.directions.route request, (result, status) ->
    if status == google.maps.DirectionsStatus.OK
      ROUTE = route = result.routes[0]
      polygon = routeToPolygon route, search_params.radius

      gmap.directionsRenderer.setDirections(result)
      gmap.onNextMovement -> callback(polygon)
    else
      alert('Nie znaleziono trasy! Spróbuj ponownie.')

printLoadRelics = (search_params, callback) ->
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

printAppendRelic = (relic) ->
  markup = """
    <div class="relic">
      <h3 class="name">#{relic.identification}</h3>
      <p class="street">#{relic.street}</p>
    </div>
    """
  $('#relics-container').append markup

printRenderRelics = (relics) ->
  relics.each (relic) ->
    printAppendRelic relic

  window.print()

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

updateWidget = (params) ->
  $form = $('form.widget_direction')
  return unless $form.length > 0
  $('#widget_direction_params').val JSON.stringify params
  $.post $form.attr('action'), $form.serialize(), (data) ->
    $('textarea#snippet').val data.snippet
  , "json"

atLeastTwoWaypoints = (waypoints) ->
  waypoints.filter (waypoint) ->
    not waypoint.isBlank()
  .length > 1

debouncedSearchRelics = jQuery.debounce ->
  if $('#search_params').length > 0
    search_params            = $.parseJSON $('#search_params').html()
  else
    search_params            = $('#new_search').serializeObject().search
    search_params.waypoints  = getWaypoints()
    search_params.route_type = $('#search_route_type :selected').val()
    search_params.radius     = $('#search_radius').val()

  search_params.api_key = "oz"
  search_params.per_page = 100
  search_params.widget = 1

  store_params = ->
    params = Object.clone search_params
    delete params.polygon
    params

  updateWidget store_params()

  if atLeastTwoWaypoints search_params.waypoints
    searchRoute search_params, (polygon) ->
      search_params.polygon = polygon.join(';')
      $('#search_polygon').val(search_params.polygon)
      # search_params.path = route.path.map((e) -> "#{e.latitude},#{e.longitude}").join(";")
      # $('#search_path').val(search_params.path)

      if bounds = gmap.getLatLngBounds()
        search_params.bounding_box = bounds.toString()

      performSearch search_params, (result) ->
        renderResults(result.clusters, result.relics)

        if printAction?
          printLoadRelics search_params, (result) ->
            printRenderRelics result.relics
  else
    performSearch search_params, (result) ->
      renderResults(result.clusters, [])

  false
, 500


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

getWaypointsFromRoute = (route) ->
  waypoints = []
  route.legs.each (leg, index) ->
    waypoints.add leg.start_address if index is 0
    leg.via_waypoints.each (wp) ->
      waypoints.add wp.toUrlValue()
    waypoints.add leg.end_address
  waypoints

updateWaypointInputs = (route, callback) ->
  waypoints = getWaypointsFromRoute route
  waypoints.each (wp, index) ->
    $input = $("#waypoints .waypoint:eq(#{index})")
    if $input.length
      $input.val(wp)
    else
      appendWaypointInput wp

  do callback

appendWaypointInput = (value = '') ->
  count = $('#waypoints .waypoint').length
  markup = """
    <div class="string clearfix optional stringish" id="search_waypoints_#{count}_input">
      <div class="input">
        <input id="search_waypoints_#{count}" name="search[waypoints[]]" type="text" value="#{value}" class="waypoint">
        <span class="remove suffix">&times;</span>
      </div>
    </div>
    """
  $('#waypoints .search-input').append markup
  $input = $('#waypoints .waypoint:last')
  placesAutocomplete $input
  $input

placesAutocomplete = (input) ->
  options = componentRestrictions: country: 'pl'
  autocomplete = new google.maps.places.Autocomplete input[0], options

  google.maps.event.addListener autocomplete, 'place_changed', ->
    $(document).trigger 'params:changed'

jQuery ->

  if printAction?
    window.gmap = new google.maps.Map $('#map_canvas')[0],
      mapTypeId: google.maps.MapTypeId.ROADMAP
  else
    window.gmap = new google.maps.Map $('#map_canvas')[0],
      mapTypeId: google.maps.MapTypeId.HYBRID

  gmap.setCenter(new google.maps.LatLng(52, 20))
  gmap.setZoom(6)

  if renderOnly?
    do searchRelics
    return

  $search = $('#new_search')

  $('a.tooltip').tooltip()
  $search.submit(searchRelics)

  $(document).on 'params:changed', ->
    ROUTE = POLYGON = null
    do searchRelics

  $('body').on 'change', '#search_radius, #waypoints .waypoint, #search_route_type', ->
    $(document).trigger 'params:changed'

  $('#waypoints a.add-place').on 'click', (e) ->
    e.preventDefault()
    $input = appendWaypointInput()
    $input.trigger 'focus'

  $('body').on 'click', '#waypoints .remove', ->
    $(this).parents('.string').remove()
    $(document).trigger 'params:changed'

  $('#waypoints .waypoint').each ->
    placesAutocomplete $(this)

  $('.categories input[type="checkbox"]').change ->
    if $(this).hasClass('sacral-options')
      filter = $(".categories div.sacral-categories")
      if $(this).is(':checked')
        filter.find('input[type=checkbox]').attr('checked', 'checked')
        filter.slideDown()
      else
        filter.find('input[type=checkbox]').removeAttr('checked')
        filter.slideUp()
    $(document).trigger 'params:changed'

  gmap.menu = new contextMenu(map: window.gmap)

  gmap.menu.addItem 'Start route here', (map, latlng) ->
    $('#waypoints .waypoint:first').val("#{latlng.lat().toFixed(6)},#{latlng.lng().toFixed(6)}")
    searchRelics()

  gmap.menu.addItem 'End route here', (map, latlng) ->
    $('#waypoints .waypoint:last').val("#{latlng.lat().toFixed(6)},#{latlng.lng().toFixed(6)}")
    searchRelics()

  gmap.onMovement ->
    if bounds = gmap.getLatLngBounds()
      $('#search_bounding_box').val(bounds.toString())
      searchRelics()

  google.maps.event.addListener gmap.directionsRenderer, 'directions_changed', ->
    ROUTE = gmap.directionsRenderer.getDirections().routes[0]
    POLYGON = null
    if ROUTE?
      updateWaypointInputs ROUTE, -> searchRelics()

  gmap.onNextMovement ->
  gmap.setCenter(new google.maps.LatLng(52, 20))
  gmap.setZoom(6)
  searchRelics()
