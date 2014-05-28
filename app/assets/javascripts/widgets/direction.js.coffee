#= require ../variables
#= require jquery
#= require jquery_ujs
#= require js-routes
#= require vendor/jquery.cookie
#= require sugar
#= require handlebars/handlebars
#= require_tree ../libraries
#= require gmaps-markerclusterer-plus/src/markerclusterer
#= require gmaps/context-menu
#= require gmaps/extras

window.gmap = null
window.marker_clusterer = null
ROUTE = null
POLYGON = null
SEARCH_PARAMS = null
SORTED_RELICS = null

print_has_prompted = false
ready_to_print = false
template = false

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

renderRelicInfo = (relic) ->
  photo = if relic.main_photo then "<div class='photo-wrapper'><img src='#{relic.main_photo.file.midi.url}' width='50' height='50'></div>" else ""
  link = "<a href='#{Routes.relic_path(relic.id)}?skip_return_path=true' target='_blank'>więcej »</a>"
  address = []
  address.add(relic.place_name) if relic.place_name
  address.add(relic.street) if relic.street
  address = address.join(', ')
  "<div class='relic-info'>#{photo}<div class='relic-info-content'><h3>#{relic.identification}</h3><div>#{address}</div><div>#{link}</div></div></div>"

loadRelicInfo = (relicId, callback) ->
  gmap.onNextMovement ->
  params = {}
  params.api_key = "oz"
  params.id = relicId
  $.get Routes.api_v1_relic_path(params), (result) ->
    callback(renderRelicInfo(result))
  , "json"

overlays = []

clearMarkers = ->
  if marker_clusterer?
    marker_clusterer.clearMarkers()
    delete window.marker_clusterer
  gmap.clearOverlays()
  for marker in gmap.markers
    marker.setMap(null) unless marker.getDraggable()
  overlays = []

markerClusterer = ->
  return marker_clusterer if marker_clusterer?

  image_urls = gmap_circles
  image_sizes = [55, 59, 75, 85, 105]
  font_sizes = [14, 14, 17, 17, 17]

  styles = image_urls.map (image, index) ->
    url: image,
    textSize: font_sizes[index]
    width: image_sizes[index]
    height: image_sizes[index]
    textColor: '#507283'

  window.marker_clusterer = new MarkerClusterer gmap, [],
    maxZoom: 18
    styles: styles
    gridSize: 40

renderResults = (search_results, last = true, callback) ->
  total = search_results.length
  $.each search_results, (index) ->
    [@id, @latitude, @longitude] = this if Object.isArray(this)

    latlng = new google.maps.LatLng(@latitude, @longitude)

    marker = new google.maps.Marker
      map: gmap
      icon: gmap_marker
      position: latlng
      clickable: true
      optimized: false

    markerClusterer().addMarker(marker)

    google.maps.event.addListener marker, 'click', =>
      loadRelicInfo @id, (content) ->
        show_content_window(marker, content)

    # run callback on the last element in the last batch
    if index == total - 1 && last
      callback() if callback?


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

simplifyPolygon = (polygon) ->
  return polygon if polygon.length < 100

  simplifyBy = Math.max(1, parseInt(polygon.length / Math.max(100, polygon.length * 0.3)))

  return polygon if simplifyBy is 1

  simplified = (p for p in polygon by simplifyBy)

  # Make sure that polygon is closed
  simplified.pop()
  simplified.add simplified.first()
  simplified

routeToPolygon = (route, distance) ->
  return POLYGON if POLYGON?

  route.path = route.overview_path.map (o) ->
    latitude: o.lat().toFixed(6), longitude: o.lng().toFixed(6)

  factory = new jsts.geom.GeometryFactory()

  coordinates = route.path.map (p) ->
    new jsts.geom.Coordinate p.latitude, p.longitude

  centerLat = Math.round route.bounds.getCenter().lat()
  centerLng = route.bounds.getCenter().lng()
  # in km
  degreeInKm = haversineDistance \
    centerLat - 0.5,
    centerLng,
    centerLat + 0.5,
    centerLng

  line_string = factory.createLineString coordinates
  buffer = line_string.buffer distance / degreeInKm

  bufferCoordinates = simplifyPolygon buffer.getCoordinates()

  paths = bufferCoordinates.map (p) ->
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
      ROUTE = result.routes[0]
      callback(routeToPolygon(ROUTE, search_params.radius))

      gmap.directionsRenderer.setDirections(result)
    else
      msg = 'Nie znaleziono trasy! Spróbuj ponownie.'
      if envConfig.development
        console.log(msg)
      else
        window.alert(msg)

printAppendRelic = (relic) ->
  return if $("#relic-#{relic.id}").length

  template ||= Handlebars.compile $('#relic-template').html()
  $('#relics-container').append template(relic)

printClearRelics = ->
  SORTED_RELICS = {}
  $('#relics-container').html ''
  $('#relics-loading-info').show()

roundToSix = (num) ->
  +(Math.round(num + "e+6")  + "e-6")

closestRoutePoint = (relic) ->
  a = Infinity
  position = 0
  distance = (p, q) ->
    roundToSix(google.maps.geometry.spherical.computeDistanceBetween(p, q))
  relicPoint = new google.maps.LatLng(relic.latitude, relic.longitude)
  ROUTE.overview_path.each (point, index) ->
    if a > (b = distance(point, relicPoint))
      position = index
      a = b
  {position, distance: a}

addRelicsToSort = (relics) ->
  relics.each (relic) ->
    closest = closestRoutePoint(relic)
    SORTED_RELICS[closest.position] ||= []
    SORTED_RELICS[closest.position][closest.distance] ||= []
    SORTED_RELICS[closest.position][closest.distance].add(relic)

getSortedRelics = ->
  sorted = []
  compare = (a, b) ->
    a - b
  Object.keys(SORTED_RELICS).each (index) ->
    Object.keys(SORTED_RELICS[index]).sort(compare).each (key) ->
      sorted.add(SORTED_RELICS[index][key])
  sorted

printRenderRelics = (relics, last) ->
  addRelicsToSort(relics)

  if last
    getSortedRelics().each (relic) ->
      printAppendRelic(relic)
    $('#relics-loading-info').hide()
    do windowPrint

windowPrint = ->
  return if print_has_prompted

  if ready_to_print
    ( ->
      print_has_prompted = true
      if envConfig.development
        console.log('`window.print()` doesn’t prompt during development')
      else
        window.print()
    ).delay 3000 # HACK: Wait 3s for markers rendering. Is there a better way? :(
  else
    ready_to_print = true

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
      msg = 'Nastąpił błąd podczas wyszukiwania zabytków.'
      if envConfig.development
        console.log(msg)
      else
        window.alert(msg)

hasValidWaypoints = (waypoints) ->
  waypoints.filter (waypoint) ->
    not waypoint.isBlank()
  .length > 1

parseRadius = (value) ->
  value = parseFloat(('' + value).replace(/[^0-9]+/, '.').replace(/[^0-9\.]/g, '')) || 0
  Math.min(100, Math.max(0.1, parseFloat(value, 10)))

getSearchParams = ->
  return SEARCH_PARAMS if SEARCH_PARAMS?

  if $('#search_params').length > 0
    search_params            = $.parseJSON $('#search_params').html()
  else
    search_params            = $('#new_search').serializeObject().search
    search_params.waypoints  = getWaypoints()
    search_params.route_type = $('input[name="search[route_type]"]:checked').val()
    search_params.radius     = parseRadius $('#search_radius').val()

  search_params.api_key = "oz"
  search_params.per_page = 1000
  search_params.widget = 1
  SEARCH_PARAMS = search_params

$('#search_radius').on 'change', ->
  this.value = parseRadius $(this).val()

saveWidget = ->
  # auto save only if has valid waypoints
  return unless hasValidWaypoints getSearchParams().waypoints

  storeParams = ->
    params = Object.clone getSearchParams()
    delete params.polygon
    params

  unless renderOnly?
    window.parent.postMessage(JSON.stringify(
      event: "on_params_changed", params: storeParams()
    ), "*")

reset = ->
  ROUTE = POLYGON = SEARCH_PARAMS = null
  clearMarkers()

searchRelics = ->
  debouncedSearchRelics()
  false

debouncedSearchRelics = jQuery.debounce ->
  search_params = getSearchParams()

  if hasValidWaypoints search_params.waypoints
    searchRoute search_params, (polygon) ->
      search_params.polygon = polygon.join(';')
      $('#search_polygon').val(search_params.polygon)

      search_params.widget = 'direction'

      if printAction?
        printClearRelics()
        renderCallback = -> windowPrint()
      else
        search_params.short = true

      loadRelics = (search_params) ->
        performSearch search_params, (result) ->
          current_page = parseInt result.meta.current_page
          total_pages  = parseInt result.meta.total_pages
          last         = current_page == total_pages

          if printAction?
            renderResults(result.relics, last, renderCallback)
            printRenderRelics(result.relics, last)
          else
            renderResults(result.relics, last)

          if current_page < total_pages
            search_params.page = current_page + 1
            loadRelics search_params

      loadRelics Object.clone(search_params)

  false
, 50

haversineDistance = (lat1, lon1, lat2, lon2) ->
  latLng1 = new google.maps.LatLng(lat1, lon1)
  latLng2 = new google.maps.LatLng(lat2, lon2)
  google.maps.geometry.spherical.computeDistanceBetween(latLng1, latLng2) / 1000

getWaypointsFromRoute = (route) ->
  waypoints = []
  currentWaypoints = getWaypoints()

  exists = (waypoint) ->
    currentWaypoints.any (current) ->
      reg = new RegExp(current, 'i')
      current == waypoint || reg.test(waypoint)

  route.legs.each (leg, index) ->
    if index == 0
      waypoints.add if exists(leg.start_address)
        leg.start_address
      else
        leg.start_location.toUrlValue()
    leg.via_waypoints.each (wp) ->
      waypoints.add wp.toUrlValue()
    waypoints.add if exists(leg.end_address)
      leg.end_address
    else
      leg.end_location.toUrlValue()
  waypoints

updateWaypointInputs = (route, callback) ->
  waypoints = getWaypointsFromRoute route
  waypoints.each (wp, index) ->
    $input = $("#waypoints .waypoint:eq(#{index})")
    if $input.length
      $input.val(wp)
    else
      appendWaypointInput wp

  callback() if callback?

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

debounceWaypointsChanged = jQuery.debounce ->
  # HACK: 'place_changed' event is triggered ~360ms after jQuery 'change' event...
  $(document).trigger 'params:changed'
, 400

placesAutocomplete = ($input) ->
  options = componentRestrictions: country: 'pl'
  autocomplete = new google.maps.places.Autocomplete $input[0], options

  google.maps.event.addListener autocomplete, 'place_changed', ->
    debounceWaypointsChanged()

  $input.on 'change', ->
    debounceWaypointsChanged()

jQuery ->

  if printAction?
    window.gmap = new google.maps.Map $('#map_canvas')[0],
      mapTypeId: google.maps.MapTypeId.ROADMAP
      disableDefaultUI: true
  else
    window.gmap = new google.maps.Map $('#map_canvas')[0],
      mapTypeId: google.maps.MapTypeId.HYBRID

  gmap.onNextMovement ->
  gmap.setCenter(new google.maps.LatLng(52, 20))
  gmap.setZoom(6)

  if renderOnly?
    searchRelics()
    return

  $search = $('#new_search')
  $search.submit(searchRelics)

  $(document).on 'params:changed', ->
    reset()
    searchRelics()
    saveWidget()

  $('body').on 'change', '#search_radius, input[name="search[route_type]"]', ->
    $(document).trigger 'params:changed'

  toggleRemoveButtons = ->
    if $('#waypoints .waypoint').length < 3
      $('#waypoints .remove').hide()
    else
      $('#waypoints .remove').each ->
        $(this).css display: ''

  $('#waypoints a.add-place').on 'click', (e) ->
    e.preventDefault()
    $input = appendWaypointInput()
    do toggleRemoveButtons
    $input.trigger 'focus'

  $('body').on 'click', '#waypoints .remove', ->
    $(this).parents('.string').remove()
    do toggleRemoveButtons
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

  gmap.menu.addItem 'Rozpocznij trasę tutaj', (map, latlng) ->
    $('#waypoints .waypoint:first').val("#{latlng.lat().toFixed(6)},#{latlng.lng().toFixed(6)}").change()

  gmap.menu.addItem 'Zakończ trasę tutaj', (map, latlng) ->
    $('#waypoints .waypoint:last').val("#{latlng.lat().toFixed(6)},#{latlng.lng().toFixed(6)}").change()

  google.maps.event.addListener gmap.directionsRenderer, 'directions_changed', ->
    newRoute = gmap.directionsRenderer.getDirections().routes[0]
    return if newRoute == ROUTE
    if newRoute
      updateWaypointInputs newRoute, ->
        $(document).trigger 'params:changed'

  $(document).trigger 'params:changed'
