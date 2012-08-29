#= require jquery
#= require jquery_ujs
#= require twitter/bootstrap/bootstrap-tooltip
#= require_tree ../libraries
#= require vendor/gmaps

window.load_google_maps = ->
  script = document.createElement("script")
  script.type = "text/javascript"
  script.src = "http://maps.googleapis.com/maps/api/js?key=#{window.google_maps_key}&sensor=false&callback=google_maps_loaded"
  document.body.appendChild(script)

window.ensuring_google_maps_loaded = (callback) ->
  if window.is_google_maps_loaded
    do callback
  else
    window.google_maps_loaded_callback = callback
    do window.load_google_maps

window.ensure_geolocation = ->
  if $('#relic_latitude').val().length > 0
    $('#map_canvas').auto_zoom()
  else
    $('#relic_latitude').val 52.4118436
    $('#relic_longitude').val 19.0984013
    try
      navigator.geolocation.getCurrentPosition (pos) ->
        $('#relic_latitude').val pos.coords.latitude
        $('#relic_longitude').val pos.coords.longitude
        $('#map_canvas').auto_zoom()

jQuery.initializer '.map_search .sidebar', ->
  $('a.tooltip').tooltip()