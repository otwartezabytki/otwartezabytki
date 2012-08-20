#= require vendor/gmaps

map = undefined

geocode_location = (callback) ->
  voivodeship = $('form.suggestion').data('voivodeship')
  district = $('form.suggestion').data('district')
  commune = $('form.suggestion').data('commune')
  city = $('#place_name_viewer').val()
  street = $('#relic_street').val()

  jQuery.get geocoder_search_path, {voivodeship, district, commune, city, street}, (result) ->
    if result.length > 0
      $('#relic_latitude').val(result[0].latitude.round(7))
      $('#relic_longitude').val(result[0].longitude.round(7))
      callback(result[0].latitude.round(7), result[0].longitude.round(7)) if callback?
    else
      callback() if callback?

$.fn.specialize

  '#map_canvas':

    map: -> map

    zoom_at: (lat, lng) ->
      if map?
        map.setCenter(lat, lng)
      else
        map = new GMaps
          div: '#map_canvas'
          width: 340
          height: 340
          zoom: 17
          lat: lat
          lng: lng
          mapTypeId: google.maps.MapTypeId.HYBRID

    auto_zoom: ->
      latitude = $('#relic_latitude').val().toNumber()
      longitude = $('#relic_longitude').val().toNumber()
      this.zoom_at(latitude, longitude)
      map.removeMarkers()
      this.circle_marker()

    circle_marker: ->
      latitude = $('#relic_latitude').val().toNumber()
      longitude = $('#relic_longitude').val().toNumber()
      map.addMarker
        lat: latitude
        lng: longitude
        icon: new google.maps.MarkerImage(small_marker_image_path, null, null, new google.maps.Point(8, 8))

    set_marker: (lat, lng) ->
      map.removeMarkers()

      marker = map.addMarker
        lat: lat
        lng: lng
        draggable: true
        dragend: (e) ->
          new_lat = marker.getPosition().lat().round(7)
          new_lng = marker.getPosition().lng().round(7)
          $('#relic_latitude').val(new_lat)
          $('#relic_longitude').val(new_lng)
          $('#map_canvas').zoom_at(new_lat, new_lng)

        $('#relic_latitude').val(lat.round(7))
        $('#relic_longitude').val(lng.round(7))

      $('#map_canvas').zoom_at(lat, lng)

    resizeNicely: ->
      setTimeout ->
        google.maps.event.trigger(map.map, 'resize')
        setTimeout ->
          $('#map_canvas').zoom_at($('#relic_latitude').val(), $('#relic_longitude').val())
        , 500
      , 500
      this

    blinking: ->
      if !this.parents('.step').hasClass('step-editing') && this.parents('.step').hasClass('step-current')
        map.counter ||= 1
        map.counter += 1
        if map.counter % 2 || this.parents('.step').hasClass('step-edit')
          this.circle_marker() if map.markers.length == 0
        else
          map.removeMarkers()

      setTimeout ->
        $('#map_canvas').blinking()
      , 1000

jQuery.initializer 'section.edit.location', ->
  $('#relic_place_id').select2()
  window.loadGMaps() if not GMaps
  $('#map_canvas').auto_zoom()