#= require browser-update
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
#= require jquery.effects.all
#= require jquery.cookie
#= require_tree ./vendor

#= require twitter/bootstrap
#= require wizard


@marker_image_path = "<%= image_path('wizard-gps-circle-with-info.png') %>"
@geocoder_search_path = "/geocoder/search"


jQuery ->
  # autocomplete
  $input = $('input.search-query')
  if $input.length > 0
    $input.autocomplete(
      html: true,
      minLength: 2
      source: (request, callback) ->
        $.getJSON "/relics/suggester", q1: request.term, callback
      select: (event, ui) ->
        window.location = ui.item.path
    )

  # highlight
  $highlightArea = $('table.search-results')
  if $highlightArea.length > 0 and gon.highlightedTags
    for tag in gon.highlightedTags
      $highlightArea.highlight(tag)

  # font resize
  toggleFontResizeButtons = () ->
    $("span.plus, span.minus").removeClass("disabled")
    $("span.minus").addClass("disabled") unless $.cookie("font-size")
    $("span.plus").addClass("disabled") if $.cookie("font-size") == "bigger"

  $("span.plus").click ->
    size = if $.cookie("font-size") == null then "big" else "bigger"
    $.cookie("font-size", size)
    $("body")
      .removeClass("big")
      .removeClass("bigger")
      .addClass(size)
    toggleFontResizeButtons()
    false

  $("span.minus").click ->
    size = if $.cookie("font-size") == "bigger" then "big" else null
    $.cookie("font-size", size)
    $("body")
      .removeClass("big")
      .removeClass("bigger")
      .addClass(size)
    toggleFontResizeButtons()
    false

  toggleFontResizeButtons()

  # bootstrap
  $("a[rel=popover]").popover()
  $(".tooltip").tooltip()
  $("a[rel=tooltip]").tooltip()
  
  #tabs
  $("#tabs").tabs()
