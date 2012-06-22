#= require jquery
#= require jquery_ujs
#= require jquery.ui.core
#= require jquery.ui.widget
#= require jquery.ui.mouse
#= require jquery.ui.position
#= require jquery.ui.draggable
#= require jquery.ui.droppable
#= require jquery.ui.button
#= require jquery.ui.dialog
#= require jquery.ui.autocomplete

#= require chosen-jquery
#= require twitter/bootstrap
#= require bootstrap
#= require wizard

@marker_image_path = "<%= image_path('arrow.png') %>"
@geocoder_search_path = "/geocoder/search"


jQuery ->
  $input = $('input.search-query')
  if $input.length > 0
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