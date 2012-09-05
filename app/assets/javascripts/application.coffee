# TODO: move all vendor requires to files where they're actually used
#= require vendor/browser-update
#= require jquery
#= require jquery_ujs
#= require jquery.ui.core
#= require jquery.ui.widget
#= require jquery.ui.mouse
#= require jquery.ui.position
#= require jquery.ui.draggable
#= require jquery.ui.droppable
#= require jquery.ui.button
#= require jquery.ui.dialog
#= require jquery.ui.autocomplete
#= require jquery.ui.tabs
#= require jquery.ui.progressbar
#= require jquery.ui.sortable
#= require ./vendor/froogaloop
#= require ./vendor/jquery.cookie
#= require ./vendor/jquery.autocomplete-html
#= require ./vendor/jquery.cycle
#= require ./vendor/jquery.iframe-transport
#= require ./vendor/jquery.fileupload
#= require ./vendor/jquery.filestyle
#= require ./vendor/jquery.highlight-3
#= require ./vendor/jquery.transition.min
#= require ./vendor/jquery.jcarousel
#= require ./vendor/jquery.tinyscrollbar.min
#= require ./vendor/redactor
#= require ./vendor/select2
#= require ./vendor/spin.min
#= require js-routes
#= require twitter/bootstrap
#= require fancybox

#= require variables
#= require_tree ./libraries
#= require_tree ./application
#= require profile

# TEMP

jQuery.initializer 'div.administrative-level', ->
  self = this
  this.on 'change', 'select', (e) ->
    params = "#{$(this).attr('name')}=#{$(this).find('option:selected').val()}"
    unless params.match(/place_id/)
      $.get '/relicbuilder/administrative_level', params, (data, status, xhr) ->
        self.replaceWith(data)
        $('div.administrative-level').initialize()

jQuery.initializer 'div.new_relic section.main', ->
  this.on 'click', 'div.places-wrapper ul li a', (e) ->
    e.preventDefault()
    $('form.relic .actions').hide()
    $('#relic_place_id').val $(this).data('place_id')
    lat = $(this).data('coordinates').split(',')[0]
    lng = $(this).data('coordinates').split(',')[1]

    $('#map_canvas').zoom_at(lat, lng)
    map.removeMarkers()
    $('#map_canvas').circle_marker(lat, lng)

  $('#location_foreign_relic').change ->
    if $(this).is(':checked')
      $('.polish-location').hide()
      $('.foreign-location').show()
    else
      $('.foreign-location').hide()
      $('.polish-location').show()

  window.ensuring_google_maps_loaded ->
    do window.ensure_geolocation
    $('#marker').draggable
      revert: true

    $('#map_canvas').droppable
      drop: (event, ui) ->

        x_offset = (ui.offset.left - $(this).offset().left + 39)
        y_offset = (ui.offset.top - $(this).offset().top + 55)

        lng = map.map.getBounds().getSouthWest().lng()
        lat = map.map.getBounds().getNorthEast().lat()
        width = map.map.getBounds().getNorthEast().lng() - map.map.getBounds().getSouthWest().lng()
        height = map.map.getBounds().getSouthWest().lat() - map.map.getBounds().getNorthEast().lat()
        marker_lat = lat + height * y_offset / $(this).height()
        marker_lng = lng + width * x_offset / $(this).width()
        $('#map_canvas').set_marker(marker_lat, marker_lng)
        $('form.relic .actions').show()

    $('#map_canvas').auto_zoom()
    $('#map_canvas').blinking()


# trigger_geolocation = (locationString) ->
#   locationArray = locationString.split(';')
#   callback =  (lat, lng) ->
#     $('#map_canvas').zoom_at(lat, lng)
#     map.removeMarkers()
#     $('#map_canvas').circle_marker(lat, lng)
#     $('form.relic').removeClass('geocoded')
#     $('#relic_geocoded').val("0")
#     $('form.relic .actions').hide()

#   voivodeship = locationArray[0]
#   district    = locationArray[1]
#   commune     = locationArray[2]
#   city        = locationArray[3]

#   jQuery.get geocoder_search_path, {voivodeship, district, commune, city}, (result) ->
#     if result.length > 0
#       callback(result[0].latitude.round(7), result[0].longitude.round(7))
#   , 'json'

$('.flash-info-permament .close').click ->
  $(".flash-info-permament").slideUp()

$(document).ready ->
  opts =
    lines: 9 # The number of lines to draw
    length: 0 # The length of each line
    width: 8 # The line thickness
    radius: 16 # The radius of the inner circle
    corners: 1 # Corner roundness (0..1)
    rotate: 0 # The rotation offset
    color: "#000" # #rgb or #rrggbb
    speed: 0.7 # Rounds per second
    trail: 40 # Afterglow percentage
    shadow: false # Whether to render a shadow
    hwaccel: false # Whether to use hardware acceleration
    className: "spinner" # The CSS class to assign to the spinner
    zIndex: 2e9 # The z-index (defaults to 2000000000)
    top: 100 # Top position relative to parent in px
    left: 332 # Left position relative to parent in px

  target = document.getElementById("spin")
  spinner = new Spinner(opts).spin(target)