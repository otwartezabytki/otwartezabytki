jQuery.initializer 'body.relics.index .main-container', ->
  search_spinner_opts =
    lines: 9 # The number of lines to draw
    length: 0 # The length of each line
    width: 8 # The line thickness
    radius: 16 # The radius of the inner circle
    corners: 1 # Corner roundness (0..1)
    rotate: 0 # The rotation offset
    color: "#000" # #rgb or #rrggbb
    speed: 0.7 # Rounds per second
    trail: 40 # Afterglow percentage
    shadow: false # Whether to render a shadow
    hwaccel: false # Whether to use hardware acceleration
    className: "spinner" # The CSS class to assign to the spinner
    zIndex: 2e9 # The z-index (defaults to 2000000000)
    top: 100 # Top position relative to parent in px
    left: 332 # Left position relative to parent in px

  this.find("#search_order").select2
    minimumResultsForSearch: 6
    dropdownCssClass: 'search-order-dropdown'
    containerCssClass: 'search-order-container'
    width: '170px'

  this.find("section.main-search a.filter-options").click (e) ->
    e.preventDefault()
    filter = $("section.second-search")
    link = $(this)
    if link.hasClass "shown"
      filter.slideUp()
      link.removeClass "shown"
    else
      filter.slideDown()
      link.addClass("shown")

  this.find('a.show-voivodeships').click (e) ->
    e.preventDefault()
    $(this).parents('li:first').remove()
    $('ul.voivodeships').show()

  this.find("nav.pagination").click ->
    $("html, body").animate({ scrollTop: 0 }, 600);

  this.on 'ajax:beforeSend', 'form[data-remote], a[data-remote]', (e, data, status, xhr) ->
    new Spinner(search_spinner_opts).spin(document.getElementById('spin'))
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