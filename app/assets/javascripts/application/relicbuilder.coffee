jQuery.initializer 'body.relicbuilders', ->
  # in one line for easy removal using sed
  $(this).find('textarea.redactor').redactor focus: false, buttons: ['bold', 'italic', 'link', 'unorderedlist'], lang: 'pl'

  this.find(".toggle_street_input").click ->
    if $('.street_input').is(':visible')
      $('.street_input').hide()
      $('.street_input input').val("")
      $(this).text("Znam dokładny adres")
    else
      $('.street_input').show()
      $(this).text("Nie da się ustalić adresu")

jQuery.initializer 'div.new_relic section.main', ->
  this.on 'click', 'div.places-wrapper ul li a', (e) ->
    e.preventDefault()
    $('form.relic .actions').hide()
    $('#relic_place_id').val $(this).data('place_id')
    lat = $(this).data('coordinates').split(',')[0]
    lng = $(this).data('coordinates').split(',')[1]

    $(window).scrollTop $(".creator-step.location").offset().top

    $('#map_canvas').zoom_at(lat, lng)
    map.removeMarkers()
    $('#map_canvas').circle_marker(lat, lng)


  $("#location_country_code, #relic_country_code").select2
    minimumResultsForSearch: 250
    dropdownCssClass: 'search-order-dropdown'
    containerCssClass: 'search-order-container'
    width: '170px'

  $('#location_relic_group').change ->
    if $(this).is(':checked')
      $('span.r_ze').show()
      $('span.r_sa').hide()
      $('input#relic_kind').attr('value', 'ZE')
    else
      $('span.r_ze').hide()
      $('span.r_sa').show()
      $('input#relic_kind').attr('value', 'SA')

  $('#location_foreign_relic').change ->
    if $(this).is(':checked')
      $('.polish-location').hide()
      $('.foreign-location').show()
    else
      $('.foreign-location').hide()
      $('.polish-location').show()

  $('#location_existence').change ->
    if $(this).is(':checked')
      $('input#relic_existence').attr('value', 'archived')
    else
      $('input#relic_existence').attr('value', 'social')

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

    $('#map_canvas').blinking()

jQuery.initializer '.main-container div.new_relic .creator-step', ->
  this.find('a.js-popover.relic-group').popover
    title: -> $("##{$(this).data("title-id")}").html()
    content: -> $("##{$(this).data("content-id")}").html()
    delay: 1000
    placement: 'top'
    html: true

jQuery.initializer '.main-container div.new_relic .creator-step', ->
  this.find('a.js-popover.non-existed').popover
    title: -> $("##{$(this).data("title-id")}").html()
    content: -> $("##{$(this).data("content-id")}").html()
    delay: 1000
    placement: 'bottom'
    html: true
