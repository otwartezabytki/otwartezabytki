geocode_polish_location = ->
  return true unless $('#map_canvas').length
  window.geocode_location (lat, lng) ->
    $('#map_canvas').zoom_at(lat, lng)
    window.map.removeMarkers()
    $('#map_canvas').circle_marker(lat, lng)
    $('form.relic').removeClass('geocoded')
    $('#relic_geocoded').val("f")

jQuery.initializer 'div.administrative-level', ->
  self = this
  this.find("#relic_voivodeship_id").select2
    minimumResultsForSearch: 20
    dropdownCssClass: 'search-order-dropdown'
    containerCssClass: 'search-order-container'
    width: '175px'

  this.find("#relic_district_id").select2
    minimumResultsForSearch: 50
    dropdownCssClass: 'search-order-dropdown'
    containerCssClass: 'search-order-container'
    width: '175px'

  this.find("#relic_commune_id").select2
    minimumResultsForSearch: 50
    dropdownCssClass: 'search-order-dropdown'
    containerCssClass: 'search-order-container'
    width: '175px'


  calculatedWidth = if this.parents('section.location').length > 0; then '175px'; else '555px'
  this.find("#relic_place_id").select2
    minimumResultsForSearch: 20
    dropdownCssClass: 'search-order-dropdown'
    containerCssClass: 'search-order-container'
    width: calculatedWidth

  this.on 'change', 'select', (e) ->
    params = "#{$(this).attr('name')}=#{$(this).find('option:selected').val()}"
    if params.match(/place_id/)
      geocode_polish_location()
    else
      $.get '/relicbuilder/administrative_level', params, (data, status, xhr) ->
        self.replaceWith(data)
        $('div.administrative-level').initialize()
        geocode_polish_location()
