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

    switchViewClass: (klass) ->
      this.saveLocalHistory()
      this.removeClass('step-done step-skipped step-confirmed step-edited step-view step-edit')
      this.addClass(klass)
      $('.step').removeClass('step-current')
      this.addClass('step-current')
      this.action().val('skip')        

    view: ->
      this.switchViewClass('step-view')
      this.find('button.edit').focus()

      this

    edit: ->
      this.switchViewClass('step-edit')
      this.input().edit()

      if this.data('autoscroll')?
        document.location.hash = this.data('autoscroll')

      this

    submit: ->
      this.switchViewClass('step-view step-done step-edited')
      this.action().val('edit')
      this.input().save()
      this.done()
      this

    confirm: ->
      this.switchViewClass('step-view step-done step-confirmed')
      this.action().val('confirm')
      this.done()
      this

    skip: ->
      this.switchViewClass('step-view step-done step-skipped')
      this.action().val('skip')
      this.done()
      this

    cancel: ->
      this.restoreHistory()
      this.input().save()
      this.view()
      this.saveLocalHistory()
      this

    done: ->
      this.addClass('step-done').removeClass("step-current")
      $('.help-extended').hide()
      $('.help-content .help').show()
      $(".help-content").removeClass("active")

      next_step = $('.step:not(.step-done):first')
      setHeight = next_step.offset().top - (($(window).height() / 2) - (next_step.height() / 2)) + 100

      setTimeout ->
        $('html,body').animate scrollTop: setHeight, ->
          next_step.view()
      , 1000

      this

    back: ->
      if $('.step-current').input().hasChanged()
        alert('Najpierw musisz skończyć edytować bieżące pole.')
      else
        if $('.step-current').hasClass('step-edit')
          $('.step-current').cancel()

        current_step = $('.step-current')

        if this.hasClass('step-edited') && !this.hasClass('step-current')
          this.edit()
        else
          this.view()

        current_step.restoreLocalHistory()

      this

    saveHistory: ->
      this.input().saveHistory()
      this.action().saveHistory()
      this

    restoreHistory: ->
      this.input().restoreHistory()
      this.action().restoreHistory()
      this

    saveLocalHistory: ->
      console.log('save')
      this.data('class', this.attr('class'))
      this.input().saveLocalHistory()
      this.action().saveLocalHistory()

    restoreLocalHistory: ->
      console.log(this.data('class'))
      this.action().restoreLocalHistory()
      this.input().restoreLocalHistory()
      this.attr('class', this.data('class'))
      this.removeClass('step-current')

    restoreLocalState: ->
      this.input().restoreLocalState()

    hasChanged: ->
      this.input().hasChanged()

  # place step have select field instead of text
  '.step-place':

    input: -> $("#suggestion_place_id")

    edit: ->
      this.switchViewClass('step-edit')
      $('#suggestion_place_id').focus()
      this

    submit: ->
      this.find('#place_name_viewer').val(this.find('#suggestion_place_id option:selected').text())
      this.switchViewClass('step-view step-done step-edited')
      this.action().val('edit')
      this.done()
      geocode_location ->
        $('#map_canvas').auto_zoom()

      this

    cancel: ->
      this.restoreHistory()
      this.input().save()
      this.find('#suggestion_place_id').val(this.input().val())
      this.find('#place_name_viewer').val(this.find('#suggestion_place_id option:selected').text())
      this.view()
      this.saveLocalHistory()
      this

  '.step-street':

    submit: ->
      this.switchViewClass('step-view step-done step-edited')
      this.action().val('edit')
      this.input().save()
      this.done()
      geocode_location ->
        $('#map_canvas').auto_zoom()
      this

  # place step have select field instead of text
  '.step-tags':

    input: -> this.find("input[type='checkbox']")

    view: ->
      this.edit()
      this

    skip: ->
      this.cancel()
      this.switchViewClass('step-view step-done step-skipped')
      this.action().val('skip')
      this.done()
      this


  '.step-gps':

    input: -> $('#suggestion_latitude, #suggestion_longitude')
    action: -> $('#suggestion_coordinates_action')

    edit: ->
      this.switchViewClass('step-edit')
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
      this.each ->
        $(this).data('history', $(this).val())
      this

    restoreHistory: ->
      this.each ->
        if $(this).data('history') != undefined
          $(this).val($(this).data('history'))
      this

    saveLocalHistory: ->
      this.each ->
        $(this).data('local_history', $(this).val())
      this

    restoreLocalHistory: ->
      this.each ->
        $(this).val($(this).data('local_history'))
      this

    hasChanged: ->
      this.toArray().some (e) ->
        console.log($(e).data('local_history'))
        $(e).data('local_history') != $(e).val()


  'input[type="checkbox"]':

    edit: ->
      this.prop('disabled', false)
      this

    save: ->
      this.prop('disabled', true)
      this

    saveHistory: ->
      this.each ->
        $(this).data('history', $(this).prop('checked'))

      this

    restoreHistory: ->
      this.each ->
        $(this).prop('checked', $(this).data('history'))

      this

    saveLocalHistory: ->
      this.each ->
        $(this).data('local_history', $(this).prop('checked'))

      this

    restoreLocalHistory: ->
      this.each ->
        $(this).prop('checked', $(this).data('local_history'))
      this

    hasChanged: ->
      this.toArray().some (e) ->
        $(e).data('local_history') !=  $(e).prop('checked')

  '#suggestion_latitude, #suggestion_longitude':
    edit: ->
    save: ->

  '#map_canvas':

    map: -> map

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

    set_marker: (lat, lng) ->
      map.removeMarkers()

      marker = map.addMarker
        lat: lat
        lng: lng
        draggable: true
        dragend: (e) ->
          new_lat = marker.getPosition().lat().round(6)
          new_lng = marker.getPosition().lng().round(6)
          $('#suggestion_latitude').val(new_lat)
          $('#suggestion_longitude').val(new_lng)
          $('#map_canvas').zoom_at(new_lat, new_lng)

        $('#suggestion_latitude').val(lat.round(6))
        $('#suggestion_longitude').val(lng.round(6))

      $('#map_canvas').zoom_at(lat, lng)

jQuery ->

  # prevent form submission until end of the wizard
  $('form.suggestion').submit (e) ->
    $('.step-submit').addClass('step-done')
    if $('.step:not(.step-done)').length > 0
      $('.step:not(.step-done):first').view()
      false
    else
      $('.steps input[disabled]').prop("disabled", false)

  # turn of autocompletion for all inputs
  $('.step input[type="text"]').attr('autocomplete', 'off')

  # disable all checkbox for now
  $('.step-tags input[type="checkbox"]').prop('disabled', true)

  # register actions for wizard
  ['edit', 'cancel', 'submit', 'confirm', 'skip', 'back'].forEach (action) ->
    $('.steps').on 'click', ".action-#{action} a" , ->
      step_div = $(this).parents('.step:first')
      step_div[action]() if step_div.hasClass('step-current')
      return false # prevent the form submission

  $('.steps').on 'click', '.action-back a', ->
    $(this).parents('.step:first').back()

  $('.step').each -> $(this).saveHistory()

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
        $('#map_canvas').set_marker(marker_lat, marker_lng)

        $(this).parents('.step').edit()

  $('#map_canvas').auto_zoom()

  $('#suggestion_latitude, #suggestion_longitude').keyup ->
    if $('#suggestion_latitude').val().length == 9 && $('#suggestion_longitude').val().length == 9
      latitude = $('#suggestion_latitude').val().toNumber()
      longitude = $('#suggestion_longitude').val().toNumber()
      if !isNaN(latitude) & !isNaN(longitude)
        $('#map_canvas').set_marker(latitude, longitude)
  
  $(".step-current .help-content .help").click ->
    $(this).parent().addClass("active")
    $(this).hide()
    $(".step-current .help-content .help-extended").show()
    
  $(".step-current .help-content .help-extended .close").click ->
    $(this).parents(".help-content").removeClass("active")
    $(this).parent().hide()
    $(".step-current .help-content .help").show()       
    
  #$('.step-gps').view()