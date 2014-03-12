#= require ../variables
#= require jquery
#= require jquery_ujs
#= require js-routes
#= require vendor/jquery.cookie
#= require twitter/bootstrap/bootstrap-tooltip
#= require_tree ../libraries
#= require vendor/antiscroll
#= require vendor/debounce.jquery

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

not_dragged = true

initialize_gmap = ->
  if !window.gmap
    window.gmap = new google.maps.Map document.getElementById('map_canvas'),
      mapTypeId: google.maps.MapTypeId.HYBRID

    prevent_next_init_event = true
    fitting_bounds = false

    old_set_zoom = google.maps.Map.prototype.setZoom
    google.maps.Map.prototype.setZoom = (zoom) ->
      zoom += 1 if fitting_bounds
      old_set_zoom.call(this, zoom)
      fitting_bounds = false

    old_fit_bounds = google.maps.Map.prototype.fitBounds
    google.maps.Map.prototype.fitBounds = (bounds) ->
      fitting_bounds = true
      prevent_next_init_event = true
      old_fit_bounds.call(this, bounds)

    init = $.throttle ->

      if prevent_next_init_event
        prevent_next_init_event = false
        return

      bounds = gmap.getBounds()
      if bounds
        north_east = bounds.getNorthEast()
        south_west = bounds.getSouthWest()
        top_left = "#{north_east.lat()},#{south_west.lng()}"
        bottom_right = "#{south_west.lat()},#{north_east.lng()}"
        $('#search_bounding_box').val("#{top_left};#{bottom_right}")
        $('#new_search').submit()
        not_dragged = false
    , 3000

    google.maps.event.addListener gmap, 'idle', init

jQuery.initializer '#map_widget', ->

  $sidebar = $(this)
  $$ = $sidebar.find.bind($sidebar)

  $('a.tooltip').tooltip()

  location_scroller = $('.locations .antiscroll-wrap').antiscroll(x: false).data('antiscroll')
  categories_scroller = $('.categories .antiscroll-wrap').antiscroll(x: false).data('antiscroll')

  $(window).resize ->
    location_scroller.refresh()
    categories_scroller.refresh()

  $('.categories input[type="checkbox"]').change ->
    if $(this).hasClass('sacral-options')
      filter = $(".categories div.sacral-categories")
      if $(this).is(':checked')
        filter.find('input[type=checkbox]').attr('checked', 'checked')
        filter.slideDown()
      else
        filter.find('input[type=checkbox]').removeAttr('checked')
        filter.slideUp()
    # submit
    $('#new_search').submit()

  $('.categories input[type="checkbox"]:disabled').each ->
    $(this).parents('choice').hide()

  if $$('.locations').length && $$('.categories').length
    $$('.locations a.show-more').click ->
      $$('.locations').animate height: '100%', ->
        location_scroller.refresh()
      $$('.locations').addClass('maxed').removeClass('mined')
      $.cookie('section-shown', 'locations')
      false

    $$('.categories a.show-more').click ->
      $$('.locations').animate height: '0%'
      $$('.categories').animate height: '100%', ->
        categories_scroller.refresh()
      $$('.categories').addClass('maxed').removeClass('mined')
      $.cookie('section-shown', 'categories')
      false

    $$('a.show-less').click ->
      $$('.locations').animate height: '60%', ->
        location_scroller.refresh()

      $$('.categories').animate height: '40%', ->
        categories_scroller.refresh()

      $$('.locations').removeClass('maxed').removeClass('mined')
      $$('.categories').removeClass('maxed').removeClass('mined')
      $.cookie('section-shown', null)
      false

  window.ensuring_google_maps_loaded ->
    one_time ->
      do extend_google_maps
      do construct_relic_marker
      do initialize_gmap

    search_params = jQuery.parseJSON($('#search_params').html())

    window.parent.postMessage(JSON.stringify(event: "on_params_changed", params: search_params), "*")

    boundingbox = if search_params.bounding_box
      [top_left, bottom_right] = search_params.bounding_box.split(';')
      top_left = top_left.split(',')
      bottom_right = bottom_right.split(',')
      [{lat: top_left[0], lng: top_left[1]}, {lat: bottom_right[0], lng: bottom_right[1]}]
    else
      $sidebar.data('boundingbox')


    if (boundingbox && not_dragged) || !gmap.getBounds()
      southWest = new google.maps.LatLng(boundingbox[0].lat, boundingbox[0].lng)
      northEast = new google.maps.LatLng(boundingbox[1].lat, boundingbox[1].lng)
      bounds = new google.maps.LatLngBounds(southWest, northEast)
      ignore_next_fit_bounds = true
      gmap.fitBounds(bounds)

    gmap.clearMarkers()
    gmap.clearOverlays()

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

    $.each $.parseJSON($('#group_markers').html()), ->
      latlng = new google.maps.LatLng(@latitude, @longitude)

      if @facet_count > 1
        new google.maps.RelicMarker latlng, @facet_count, gmap, =>
          not_dragged = true
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
    if results = jQuery.parseJSON($('#search_results').html())
      $.each results, ->
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

  $sidebar.find('.categories .choices-group label, .locations .locations_tree li').on 'mouseenter', ->
    $name = $(this).find('.name')
    name = $name[0]
    if name && name.offsetWidth < name.scrollWidth
      $(this).attr('title', $name.text())
      $(this).tooltip('show')
