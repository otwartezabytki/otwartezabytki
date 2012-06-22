#= require sugar
#= require jquery-specializer

map = undefined

geocode_location = (callback) ->
  voivodeship = $('form.suggestion').data('voivodeship')
  district = $('form.suggestion').data('district')
  commune = $('form.suggestion').data('commune')
  city = $('#place_name_viewer').val()
  street = $('#suggestion_street').val()

  jQuery.get geocoder_search_path, {voivodeship, district, commune, city, street}, (result) ->
    if result.length > 0
      $('#suggestion_latitude').val(result[0].latitude.round(6))
      $('#suggestion_longitude').val(result[0].longitude.round(6))
      callback(result[0].latitude.round(6), result[0].longitude.round(6)) if callback?
    else
      callback() if callback?

$.fn.specialize

  '.step':

    input: -> this.find("input[type='text']")
    action: -> this.find("#" + this.input().attr('id') + '_action')

    view: ->
      this.removeClass('step-skipped step-confirmed step-done')

      # when clicking back button
      if (this.hasClass('step-edited') || this.hasClass('step-edit')) && !this.hasClass('step-current')
        $('.step').removeClass('step-current')
        return this.edit()

      this.addClass('step-current')
      this.removeClass('step-edit').addClass('step-view')
      this.find('button.edit').focus()

      if this.data('autoscroll')?
        document.location.hash = this.data('autoscroll')

      this

    edit: ->
      this.addClass('step-current')
      this.removeClass('step-view step-edited').addClass('step-edit')
      this.input().edit()

      if this.data('autoscroll')?
        document.location.hash = this.data('autoscroll')

      this

    submit: ->
      this.removeClass('step-edit').addClass('step-view')
      this.input().save()
      this.markAs('edit')
      this.done()
      this

    cancel: ->
      this.input().restoreHistory().save()
      this.view()
      this

    confirm: ->
      this.markAs('confirm')
      this.done()
      this

    skip: ->
      this.markAs('skip')
      this.done()
      this

    done: ->
      this.addClass('step-done').removeClass('step-current')
      $('.step:not(.step-done):first').view()
      this

    back: ->
      this.view()
      this

    markAs: (action) ->

      this.removeClass('step-confirmed step-skipped step-edited')
          .addClass('step-' + (if action == 'skip' then 'skipp' else action) + 'ed')

      this.action().val(action);

  # place step have select field instead of text
  '.step-place':

    input: -> $("#suggestion_place_id")

    edit: ->
      this.addClass('step-current')
      this.removeClass('step-view step-edited').addClass('step-edit')
      $('#suggestion_place_id').focus()
      this

    submit: ->
      this.find('#place_name_viewer').val(this.find('#suggestion_place_id option:selected').text())
      this.removeClass('step-edit').addClass('step-view')
      this.markAs('edit')
      this.done()
      geocode_location ->
        $('#map_canvas').auto_zoom()

      this

    cancel: ->
      this.input().restoreHistory().save()
      this.find('#suggestion_place_id').val(this.input().val())
      this.find('#place_name_viewer').val(this.find('#suggestion_place_id option:selected').text())
      this.view()
      this

  '.step-street':

    submit: ->
      this.removeClass('step-edit').addClass('step-view')
      this.input().save()
      this.markAs('edit')
      this.done()
      geocode_location ->
        $('#map_canvas').auto_zoom()
      this

  # place step have select field instead of text
  '.step-tags':

    input: -> this.find("#suggestion_tags")

    edit: ->
      this.addClass('step-current')
      this.removeClass('step-view step-edited').addClass('step-edit')
      $('#suggestion_tags_chzn').mousedown()
      this

    submit: ->
      this.find('#tags_viewer').val((this.input().val() || []).join(', '))
      this.removeClass('step-edit').addClass('step-view')
      this.markAs('edit')
      this.done()
      this

    cancel: ->
      this.removeClass('step-edit').addClass('step-view')
      this.input().restoreHistory()
      this.find('#tags_viewer').val((this.input().val() || []).join(', '))
      this.view()

      this

  '.step-gps':

    input: -> $('#suggestion_latitude, #suggestion_longitude')
    action: -> $('#suggestion_coordinates_action')

    edit: ->
      this.addClass('step-current')
      this.removeClass('step-view step-edited').addClass('step-edit')
      this

    cancel: ->
      this.removeClass('step-edit').addClass('step-view')
      $('#suggestion_latitude, #suggestion_longitude').restoreHistory()
      map.removeMarkers()
      this.view()

      this


  'input, select':

    edit: ->
      this.prop('readonly', false)
      this.prop('placeholder', '')
      this.focus().val(this.val())
      this

    save: ->
      this.prop('readonly', true)
      this.prop('placeholder', 'Brak danych')
      this.blur()
      this

    saveHistory: ->
      this.data('history', this.val())
      this

    restoreHistory: ->
      if this.data('history') != undefined
        this.val(this.data('history')).trigger('liszt:updated')
      this

  '#map_canvas':

    zoom_at: (lat, lng) ->
      if map?
        map.setCenter(lat, lng)
      else
        map = new GMaps(div: '#map_canvas', width: 900, height: 500, zoom: 14, lat: lat, lng: lng, mapTypeId: google.maps.MapTypeId.HYBRID)

    auto_zoom: ->
      zoom_map = (lat, lng) =>
        $(this).zoom_at(lat, lng)
        if $('#suggestion_street').val().length > 0
          map.removeMarkers()
          map.addMarker
            lat: lat
            lng: lng
            icon: new google.maps.MarkerImage(marker_image_path, null, null, new google.maps.Point(62, 33))

      latitude = $('#suggestion_latitude').val().toNumber()
      longitude = $('#suggestion_longitude').val().toNumber()
      if !isNaN(latitude) & !isNaN(longitude)
        zoom_map(latitude, longitude)
      else
        geocode_location(zoom_map)


jQuery ->

  # prevent form submission until end of the wizard
  $('form.relic').submit (e) -> e.preventDefault() unless $(this).data('complete') is true

  # turn of autocompletion for all inputs
  $('.step input[type="text"]').attr('autocomplete', 'off')

  # turn on chosen inputs
  $('#suggestion_tags').chosen({ no_results_text: "Brak pasujących kategorii" });

  # register actions for wizard
  ['edit', 'submit', 'cancel', 'confirm', 'skip', 'back'].forEach (action) ->
    $('.steps').on 'click', ".action-#{action} a" , ->
      $(this).parents('.step:first')[action]()
      return false # prevent the form submission

  $('.step:first').view()

  $('.step').each ->
    $(this).input().saveHistory()

  $('#marker').draggable(revert: true)

  $('#map_canvas').droppable
    drop: (event, ui) ->

      x_offset = (ui.offset.left - $(this).offset().left + 10)
      y_offset = (ui.offset.top - $(this).offset().top + 35)
      container_height = $(this).parents('.step').find('.actions-view').height()
      container_width =  $(this).parents('.step').find('.actions-view').width()

      if y_offset < $(this).height() - container_height || x_offset < $(this).width() - container_width

        lng = map.map.getBounds().getSouthWest().lng()
        lat = map.map.getBounds().getNorthEast().lat()
        width = map.map.getBounds().getNorthEast().lng() - map.map.getBounds().getSouthWest().lng()
        height = map.map.getBounds().getSouthWest().lat() - map.map.getBounds().getNorthEast().lat()


        marker_lat = lat + height * y_offset / $(this).height()
        marker_lng = lng + width * x_offset / $(this).width()
        marker = map.addMarker
          lat: marker_lat
          lng: marker_lng
          draggable: true
          dragend: (e) ->
            $('#suggestion_latitude').val(marker.getPosition().lat().round(6))
            $('#suggestion_longitude').val(marker.getPosition().lng().round(6))

        $('#suggestion_latitude').val(marker_lat.round(6))
        $('#suggestion_longitude').val(marker_lng.round(6))

        $(this).parents('.step').edit()

  $('#map_canvas').auto_zoom()

  $('#suggestion_latitude, #suggestion_longitude').keyup ->
    if $('#suggestion_latitude').val().length == 9 && $('#suggestion_longitude').val().length == 9
      latitude = $('#suggestion_latitude').val().toNumber()
      longitude = $('#suggestion_longitude').val().toNumber()
      if !isNaN(latitude) & !isNaN(longitude)
        $('#map_canvas').zoom_at(latitude, longitude)

  # new category remote form
  $('#new_tag').dialog
    autoOpen: false
    modal: true

  $('#new_tag').submit ->
    tag_name = $('#tag_name').val()
    $('#suggestion_tags').append("<option name='#{tag_name}'>#{tag_name}</option>")
    $('#suggestion_tags').val(($('#suggestion_tags').val() || []).concat([tag_name]).filter((e) -> e != ""))
    $('#suggestion_tags').trigger('liszt:updated')
    $('#new_tag').dialog("close")

  $('#new_tag').ajaxError (event, response) ->
    alert(jQuery.parseJSON(response.responseText).error_message)

  $('#add_category').click ->
    $("#new_tag").dialog("open")
    return false

