jQuery.initializer 'body.relics.index .main-container', ->
  this.on 'ajax:beforeSend', 'form[data-remote], a[data-remote]', (e, data, status, xhr) ->
    $('form section.results .loading').show()

  this.on 'ajax:complete', 'form[data-remote], a[data-remote]', (e, data, status, xhr) ->
    $('form section.results .loading').hide()

  this.find("input.autocomplete-q").autocomplete
    html: true,
    minLength: 2,
    source: (request, callback) ->
      $.getJSON "/suggester/query", $('form').serialize(), callback
    select: (event, ui) ->
      $('form').submit( )

  this.find('input.autocomplete-place').autocomplete
    html: true,
    minLength: 2,
    source: (request, callback) ->
      $.getJSON "/suggester/place", $('form').serialize(), callback
    select: (event, ui) ->
      $('form input#search_location').val(ui.item.location)
      $('form').submit()

  this.find('input[type=checkbox]').click ->
    $(this).parents('form:first').submit()

  this.find('select').change ->
    $(this).parents('form:first').submit()

  relics_results = this.find('div.search-results .relic')
  if relics_results.length > 0 and gon.highlightedTags
    for tag in gon.highlightedTags
      relics_results.highlight(tag)