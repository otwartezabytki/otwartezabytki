#= require ../variables
#= require jquery
#= require jquery_ujs
#= require vendor/jquery.cookie
#= require twitter/bootstrap/bootstrap-tooltip
#= require_tree ../libraries
#= require vendor/gmaps
#= require vendor/antiscroll

window.gmap = null

window.default_options =

window.load_google_maps = ->
  script = document.createElement("script")
  script.type = "text/javascript"
  script.src = "http://maps.googleapis.com/maps/api/js?key=#{window.google_maps_key}&sensor=false&callback=google_maps_loaded"
  document.body.appendChild(script)

window.google_maps_loaded = ->
  window.is_google_maps_loaded = true
  window.loadGMaps() if not GMaps
  do window.google_maps_loaded_callback if window.google_maps_loaded_callback

window.ensuring_google_maps_loaded = (callback) ->
  if window.is_google_maps_loaded
    do callback
  else
    window.google_maps_loaded_callback = callback
    do window.load_google_maps

jQuery.initializer '.sidebar', ->

  $sidebar = $(this)
  $$ = $sidebar.find.bind($sidebar)

  $('a.tooltip').tooltip()

  window.ensuring_google_maps_loaded ->
    if !window.gmap && GMaps?
      window.gmap = new GMaps
        div: '#map_canvas'
        mapTypeId: google.maps.MapTypeId.HYBRID

    location_scroller = $('.locations .antiscroll-wrap').antiscroll(x: false).data('antiscroll')
    categories_scroller = $('.categories .antiscroll-wrap').antiscroll(x: false).data('antiscroll')

    $(window).resize ->
      location_scroller.refresh()
      categories_scroller.refresh()

    $('#search_categories_input input[type="checkbox"]').change ->
      $('#new_search').submit()

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