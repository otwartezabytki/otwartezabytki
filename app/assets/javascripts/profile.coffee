#jQuery ->
#  $('section.description').on 'click', 'a[data-ajax=true]', ->
#    jQuery.get this.href, (data) ->
#      $('section.description').html($(data).find('section.description').html())
#      window.documentLoaded($('section.description'))
#
#    false
#
#  $('section.description').on 'ajax:success', 'form', (event, data) ->
#    $('section.description').html($(data).find('section.description').html())
#    window.documentLoaded($('section.description'))

#= require sugar
#= require jquery-specializer
#= require gmaps

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


jQuery ->
  $(".edit_relic").on "click", ".help-content .help, .help-extended .close", ->
    $(this).parents(".help-content").toggleClass('active')

    false


  $(document).find('textarea.redactor').redactor
    focus: false
    buttons: ['bold', 'italic', 'link', 'unorderedlist']
    lang: 'pl'

  $('#relic_tags').select2
    query: (query) -> $.get('/tags?query=q', (tags) -> query.callback({ results: tags }))
    initSelection: (element, callback) ->
      data = []
      $(element.val().split(',')).each(-> data.push({ id: this, text: this }))
      callback(data)
    multiple: true

  $('#relic_place_id').select2()


window.google_maps_loaded = ->
  jQuery ->
    window.loadGMaps();
    $('#map_canvas').auto_zoom()

jQuery ->
  return unless $('section.photos').length

  upload_spinner_opts =
    lines: 8
    length: 0
    width: 6
    radius: 10
    rotate: 0
    color: '#555'
    speed: 0.8
    trail: 55
    shadow: false
    hwaccel: false
    className: 'spinner'
    zIndex: 2e9
    top: 46
    left: 46

  if $('.preview-placeholder').length
    spinner = new Spinner(upload_spinner_opts).spin($('.preview-placeholder')[0])

  $('.progressbar').progressbar(value: 0, change: (e) -> $(e.target).find('.value').text($('.progressbar').progressbar("value") + "%"))

  photo_xhr = $(".photo_upload").fileupload
    type: "POST"
    dataType: "json"

    add: (e, data) ->
      $('.photo.hidden').removeClass('hidden')
      $(".photo_upload").hide()
      data.submit()

    submit: (e, data) ->
      data.formData = { foo: "bar" }
RAILS
    progressall: (e, data) ->
      progress = parseInt(data.loaded / data.total * 100, 10)
      $('.progressbar').progressbar("value", progress)

    done: (e, data) ->
      document.location.reload()

  $('.cancel_upload').click ->
    photo_xhr.abort() if photo_xhr?

  $('.remove_photo').click ->
    $(this).parents('.photo:first').find('input[name*="_destroy"]').val(true)
    $(this).parents('form:first').submit()
    false

  $('form.relic').submit ->
    if $('#relic_license_agreement:checked').length == 0
      confirm('Ponieważ nie posiadasz praw do publikowania tych zdjęć, zostaną one usunięte. Kontynuować?')
    else
      true