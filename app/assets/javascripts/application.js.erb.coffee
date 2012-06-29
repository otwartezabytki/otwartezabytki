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
#= require jquery.ui.tabs 
#= require jquery.transition.min

#= require chosen-jquery
#= require twitter/bootstrap
#= require wizard
#= require_tree ./vendor

@marker_image_path = "<%= image_path('arrow.png') %>"
@geocoder_search_path = "/geocoder/search"


jQuery ->
  # autocomplete
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

  # highlight
  $highlightArea = $('table.search-results')
  if $highlightArea.length > 0 and gon.highlightedTags
    for tag in gon.highlightedTags
      $highlightArea.highlight(tag)

  # font resize
  $("span.plus").click ->
    currentFontSize = $("html").css("font-size")
    currentFontSizeNum = parseFloat(currentFontSize, 10)
    newFontSize = currentFontSizeNum * 1.2
    $("html").css "font-size", newFontSize
    false

  $("span.minus").click ->
    currentFontSize = $("html").css("font-size")
    currentFontSizeNum = parseFloat(currentFontSize, 10)
    newFontSize = currentFontSizeNum * 0.8
    $("html").css "font-size", newFontSize
    false                          

  # bootstrap
  $("a[rel=popover]").popover()
  $(".tooltip").tooltip()
  $("a[rel=tooltip]").tooltip()
  
  #tabs
  $("#tabs").tabs()