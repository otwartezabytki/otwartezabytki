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

remember_values = (context, selector, remove_context, remove_selector) ->
  $(context).on 'keyup', selector, ->
    $.cookie(window.location.href + '/' + $(this).attr('id'), $(this).val())

  $(context).find(selector).each ->
    value = $.cookie(window.location.href + '/' + $(this).attr('id'))
    $(this).val(value) if $(this).val().length == 0 && value

  $(context).find(remove_selector).click ->
    $(this).parents(remove_context + ":first").find(selector).each ->
      $.cookie(window.location.href + '/' + $(this).attr('id'), '')

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

jQuery.initializer 'section.show.photos', ->
  $section = this
  if slider = $section.find('#slider_mini')[0]
    photos = $(slider).data('photos')
    $(slider).jcarousel
      size: photos.length
      itemLoadCallback:
        onBeforeAnimation: (carousel, state) ->
          for i in [carousel.first..carousel.last]
            continue if carousel.has(i)
            break if i > photos.length
            item = photos[i - 1]
            carousel.add(i, "<a href='#{Routes.relic_photo_path(item.relic_id, item.id)}' data-maxi='#{item.file.maxi.url}'><img src='#{item.file.mini.url}' width='80' height='60' alt='Zdjęcie zrobione przez #{item.author}' /></a>")

    $(slider).on 'click', 'a[data-maxi]', ->
      $section.find('.main-photo img').attr('src', $(this).data('maxi'))
      $section.find('.main-photo').attr('href', $(this).attr('href'))
      false

jQuery.initializer 'section.show.photo', ->
  $section = this
  if slider = $section.find('#slider_midi')[0]
    photos = $(slider).data('photos')
    $(slider).jcarousel
      size: photos.length
      itemLoadCallback:
        onBeforeAnimation: (carousel, state) ->
          for i in [carousel.first..carousel.last]
            continue if carousel.has(i)
            break if i > photos.length
            item = photos[i - 1]
            carousel.add(i, "<a data-remote='true' href='#{Routes.relic_photo_path(item.relic_id, item.id)}' data-main='#{item.main}'><img src='#{item.file.midi.url}' alt='Zdjęcie zrobione przez #{item.author}' /></a>")

jQuery.initializer 'section.edit.photos', ->
  $section = $(this)
  $preview_placeholder = $section.find('.preview-placeholder')
  $progressbar = $section.find('.progressbar')
  $photo_hidden = $section.find('.photo.hidden')
  $photo_upload = $section.find(".photo_upload")
  $form = $section.find('form.relic')
  $cancel_upload = $section.find('.cancel_upload')
  $remove_photo = $section.find('.remove_photo')

  upload_spinner_opts = {
    lines: 8, length: 0, width: 6, radius: 10, rotate: 0, color: '#555', speed: 0.8, trail: 55,
    shadow: false, hwaccel: false, className: 'spinner', zIndex: 2e9, top: 46, left: 46
  }

  if $preview_placeholder.length
    spinner = new Spinner(upload_spinner_opts).spin($preview_placeholder[0])

  $progressbar.progressbar
    value: 0,
    change: (e) ->
      $(e.target).find('.value').text($progressbar.progressbar("value") + "%")

  photo_xhr = $(".photo_upload").fileupload
    type: "POST"
    dataType: "html"

    add: (e, data) ->
      $photo_hidden.removeClass('hidden')
      $photo_upload.hide()
      data.submit()

    submit: (e, data) ->
      data.formData = {}

    progressall: (e, data) ->
      progress = parseInt(data.loaded / data.total * 100, 10)
      $progressbar.progressbar("value", progress)

    done: (e, data) ->
      $new_section = $(data.result).find('section.edit')
      $section.replaceWith($new_section)
      $new_section.initialize()

  $cancel_upload.click ->
    photo_xhr.abort() if photo_xhr?

  $remove_photo.click ->
    $(this).parents('.photo:first').find('input[type="text"]').each ->
      $.cookie($(this).attr('id'), '')

  $form.submit ->
    if $section.find('#relic_license_agreement:checked').length == 0
      confirm('Ponieważ nie posiadasz praw do publikowania tych zdjęć, zostaną one usunięte. Kontynuować?')
    else
      true

  $section.on 'keyup', 'input.author', ->
    $input = $(this)
    $input.addClass('edited')
    $section.find("input.author:not(.edited)").each ->
      if $(this).hasClass('connected') || $(this).val().length == 0
        $(this).val($input.val()).addClass('connected')
        $(this).trigger('change')

  $section.on 'keyup', 'input.date_taken', ->
    $input = $(this)
    $input.addClass('edited')
    $section.find("input.date_taken:not(.edited)").each ->
      if $(this).hasClass('connected') || $(this).val().length == 0
        $(this).val($input.val()).addClass('connected')
        $(this).trigger('change')

  $section.on 'change', 'input.date_taken, input.author', ->
    $.cookie($(this).attr('id'), $(this).val())

  $section.find('input.date_taken, input.author').each ->
    $(this).val($.cookie($(this).attr('id'))) if $(this).val().length == 0 && $.cookie($(this).attr('id'))

  $("#photo_file").filestyle
    image: "/assets/photo-upload.png"
    imageheight: 25
    imagewidth: 154
    width: 154


jQuery.initializer 'section.edit.documents', ->
  $section = $(this)
  $preview_placeholder = $section.find('.preview-placeholder')
  $progressbar = $section.find('.progressbar')
  $document_hidden = $section.find('.document.hidden')
  $document_upload = $section.find(".document_upload")
  $form = $section.find('form.relic')
  $cancel_upload = $section.find('.cancel_upload')
  $remove_document = $section.find('.remove_document')

  upload_spinner_opts = {
    lines: 8, length: 0, width: 6, radius: 10, rotate: 0, color: '#555', speed: 0.8, trail: 55,
    shadow: false, hwaccel: false, className: 'spinner', zIndex: 2e9, top: 16, left: 16
  }

  if $preview_placeholder.length
    spinner = new Spinner(upload_spinner_opts).spin($preview_placeholder[0])

  $progressbar.progressbar
    value: 0,
    change: (e) ->
      $(e.target).find('.value').text($progressbar.progressbar("value") + "%")

  document_xhr = $(".document_upload").fileupload
    type: "POST"
    dataType: "html"

    add: (e, data) ->
      $document_hidden.removeClass('hidden')
      $document_upload.hide()
      data.submit()

    submit: (e, data) ->
      data.formData = {}

    progressall: (e, data) ->
      progress = parseInt(data.loaded / data.total * 100, 10)
      $progressbar.progressbar("value", progress)

    done: (e, data) ->
      $new_section = $(data.result).find('section.edit')
      $section.replaceWith($new_section)
      $new_section.initialize()

  $cancel_upload.click ->
    document_xhr.abort() if document_xhr?

  $remove_document.click ->
    $(this).parents('.document:first').find('input[type="text"]').each ->
      $.cookie($(this).attr('id'), '')

  $section.on 'change', 'input.name, input.description', ->
    $.cookie($(this).attr('id'), $(this).val())

  $section.find('input.name, input.description').each ->
    $(this).val($.cookie($(this).attr('id'))) if $(this).val().length == 0 && $.cookie($(this).attr('id'))

  $("#document_file").filestyle
    image: "/assets/file-upload.png"
    imageheight: 25
    imagewidth: 134
    width: 134

jQuery.initializer 'section.edit.description', ->
  $(this).find('textarea.redactor').redactor
    focus: false
    buttons: ['bold', 'italic', 'link', 'unorderedlist']
    lang: 'pl'

jQuery.initializer 'section.edit.categories', ->
  $('#relic_tags').select2
    query: (query) -> $.get('/tags?query=q', (tags) -> query.callback({ results: tags }))
    initSelection: (element, callback) ->
      data = []
      $(element.val().split(',')).each(-> data.push({ id: this, text: this }))
      callback(data)
    multiple: true

jQuery.initializer 'section.edit.location', ->
  $('#relic_place_id').select2()
  window.loadGMaps() if not GMaps
  $('#map_canvas').auto_zoom()

jQuery.initializer 'section.edit.entries, section.edit.entries .entries-showcase', ->
  $(this).find('textarea.redactor:first').redactor
    focus: false
    buttons: ['bold', 'italic', 'link', 'unorderedlist']
    lang: 'pl'

jQuery.initializer 'section.show.events', ->
  $("#scrollbar").tinyscrollbar()

jQuery.initializer 'section.show.general', ->
  $(this).find("#relic_location_popover").popover
    title: -> $("##{$(this).data("title-id")}").html()
    content: -> $("##{$(this).data("content-id")}").html()
    delay: 100000

  $(this).find("#relic_location_popover").click ->
    $(this).popover('toggle')
    false

$('body').on "click", ".close_popover", ->
  $("##{$(this).data('popover-id')}").popover('hide')
  false

jQuery.initializer 'section.edit.events', ->
  $section = $(this)

  $('.add_event').click ->
    template = $($(this).data('template'))
    html = template.html()
    next_id = parseInt(template.data('next-id'))
    template.data('next-id', next_id + 1)
    html = html.replace(/\[\d+\]/g, "[#{next_id}]")
    html = html.replace(/_\d+_/g, "_#{next_id}_")
    $(html).appendTo(template.parent())
    $section.find('.event-position').each (index) ->
      $(this).val(index + 1)
    false

  $(this).on 'click', '.remove_event', ->
    if confirm("Czy na pewno?")
      $(this).parents('.event:first').hide()
      $(this).parents('.event:first').find('input[name*="_destroy"]').val("1")
    false

  $(this).find('ol.sortable').sortable
    axis: 'y'
    update: ->
      $section.find('.event-position').each (index) ->
        $(this).val(index + 1)

jQuery.initializer 'section.edit.links', ->
  $section = $(this)

  $(this).on 'click', '.add_link', ->
    template = $($(this).data('template'))
    html = template.html()
    next_id = parseInt(template.data('next-id'))
    template.data('next-id', next_id + 1)
    html = html.replace(/\[\d+\]/g, "[#{next_id}]")
    html = html.replace(/_\d+_/g, "_#{next_id}_")
    $(html).appendTo(template.parent())
    $section.find('.link-position').each (index) ->
      $(this).val(index + 1)
    $('#links_container').show()
    false

  $(this).on 'click', '.remove_link', ->
    if confirm("Czy na pewno?")
      $(this).parents('.link:first').hide()
      $(this).parents('.link:first').find('input[name*="_destroy"]').val("1")
      $('#links_container').hide() if $('.link:visible').length == 0
    false

  $(this).find('ol.sortable').sortable
    axis: 'y'
    update: ->
      $section.find('.link-position').each (index) ->
        $(this).val(index + 1)