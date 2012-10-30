jQuery.initializer 'body.show.resource_home', ->
  this.find('#map-poland').cssMap
    size: 340
    onClick: (li) ->
      window.location = $(li).attr('redirect')

  this.find("input.autocomplete-q").autocomplete
    html: true,
    minLength: 2,
    source: (request, callback) ->
      $.getJSON "/suggester/query", $('form').serialize(), callback
    select: (event, ui) ->
      $('form').submit()

  this.find('input.autocomplete-place').autocomplete
    html: true,
    minLength: 2,
    source: (request, callback) ->
      $.getJSON "/suggester/place", $('form').serialize(), callback
    select: (event, ui) ->
      $('form input#search_location').val(ui.item.location)
      $('form').submit()