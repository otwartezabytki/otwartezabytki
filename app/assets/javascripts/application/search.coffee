jQuery.initializer 'body.relics.index', ->
  this.find("input.autocomplete-q").autocomplete
    html: true,
    minLength: 2,
    source: (request, callback) ->
      $.getJSON "/suggester/query", $('form.form-advance-search').serialize(), callback
    select: (event, ui) ->
      $('form.form-advance-search').submit( )

  this.find('input.autocomplete-place').autocomplete
    html: true,
    minLength: 2,
    source: (request, callback) ->
      $.getJSON "/suggester/place", $('form.form-advance-search').serialize(), callback
    select: (event, ui) ->
      $('form.form-advance-search input#search_location').val(ui.item.location)
      $('form.form-advance-search').submit()

  this.find('input[type=checkbox]').click ->
    this.parents('form:first').submit()

  relics_results = this.find('div.search-results .relic')
  if relics_results.length > 0 and gon.highlightedTags
    for tag in gon.highlightedTags
      relics_results.highlight(tag)