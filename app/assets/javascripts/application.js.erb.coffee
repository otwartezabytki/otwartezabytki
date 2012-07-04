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
#= require_tree ./vendor

#= require twitter/bootstrap
#= require wizard


@marker_image_path = "<%= image_path('wizard-gps-circle-with-info.png') %>"
@small_marker_image_path = "<%= image_path('wizard-gps-circle.png') %>"
@geocoder_search_path = "/geocoder/search"


jQuery ->
  # autocomplete
  $input = $('input.search-query')
  if $input.length > 0
    $input.autocomplete(
      html: true,
      minLength: 2,
      delay: 1000
      source: (request, callback) ->
        $.getJSON "/relics/suggester", q1: request.term, callback
      select: (event, ui) ->
        window.location = ui.item.path
    )

  # highlight
  $highlightArea = $('div.search-results .relic')
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

  # jquery footer cycle
  jQuery(".partner-slider-1, .partner-slider-2, .partner-slider-3").cycle({
    fx: 'fade',
    speed:    0,
    timeout:  4000
  })

if document.body.className.match(/thank_you/)
  window.fbAsyncInit = ->
    FB.init
      appId: "179800448818038"
      status: true
      cookie: true
      xfbml: true

    document.getElementById("share").onclick = ->
      obj =
        method: "feed"
        redirect_uri: "http://#{document.location.hostname}/facebook/share_close"
        link: "http://#{document.location.hostname}"
        name: "Otwarte Zabytki"
        caption: "społecznościowa akcja tworzenia bazy zabytków. Dołącz!"
        picture: "http://#{document.location.hostname}<%= image_path('logo-facebook.jpg') %>"
        display: "popup"

      FB.ui obj

  js = undefined
  id = "facebook-jssdk"
  ref = document.getElementsByTagName("script")[0]
  return if document.getElementById(id)
  js = document.createElement("script")
  js.id = id
  js.async = true
  js.src = "//connect.facebook.net/pl_PL/all.js"
  ref.parentNode.insertBefore js, ref
