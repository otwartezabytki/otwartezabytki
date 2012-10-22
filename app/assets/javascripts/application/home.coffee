jQuery.initializer 'body.show.resource_home', ->
  # jquery footer cycle
  jQuery(".partner-slider-1, .partner-slider-2, .partner-slider-3").cycle
    fx: 'fade',
    speed:    0,
    timeout:  4000

  $('#map-poland').cssMap
    size: 340
    onClick: (li) ->
      window.location = $(li).attr('redirect')