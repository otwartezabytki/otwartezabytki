jQuery.initializer 'input.autocomplete-q', ->
  this.autocomplete(
    html: true,
    minLength: 2,
    source: (request, callback) ->
      $.getJSON "/suggester/query", $('form.form-advance-search').serialize(), callback
    select: (event, ui) ->
      $('form.form-advance-search').submit( )
  )

jQuery.initializer 'input.autocomplete-place', ->
  this.autocomplete(
    html: true,
    minLength: 2,
    source: (request, callback) ->
      $.getJSON "/suggester/place", $('form.form-advance-search').serialize(), callback
    select: (event, ui) ->
      $('form.form-advance-search input#search_location').val(ui.item.location)
      $('form.form-advance-search').submit( )
  )

jQuery.initializer 'input[type=checkbox]', ->
  this.click =>
    this.parents('form:first').submit()

jQuery.initializer 'div.search-results .relic', ->
  if this.length > 0 and gon.highlightedTags
    for tag in gon.highlightedTags
      this.highlight(tag)