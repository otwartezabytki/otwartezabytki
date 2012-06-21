#= require jquery
#= require jquery_ujs
#= require twitter/bootstrap
#= require bootstrap
#= require jquery.ui.all

jQuery ->
  $input = $('input.search-query')
  $input.autocomplete(
    minLength: 2
    source: (request, callback) ->
      $.getJSON "/relics/suggester", q1: request.term, callback
    select: (event, ui) ->
      window.location = ui.item.path
  )

  $input.data("autocomplete")._renderItem = (ul, item) =>
    $("<li></li>")
    .data("item.autocomplete", item)
    .append("<a>" + item.label + "</a>")
    .appendTo(ul)