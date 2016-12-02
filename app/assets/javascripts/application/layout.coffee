jQuery ->
  # font resize
  toggleFontResizeButtons = () ->
    $(".js-plus, .js-minus").removeClass("oz-disabled")
    $(".js-minus").addClass("oz-disabled") unless $.cookie("font-size")
    $(".js-plus").addClass("oz-disabled") if $.cookie("font-size") == "bigger"

  $(".js-plus").click ->
    size = if $.cookie("font-size") == null then "big" else "bigger"
    $.cookie("font-size", size)
    $("body")
      .removeClass("big")
      .removeClass("bigger")
      .addClass(size)
    toggleFontResizeButtons()
    false

  if sessionStorage.getItem("accept_cookies") == null 
    $("#cookies").css('display', 'inline-flex')
  $("#accept_cookies").click ->
    sessionStorage.setItem("accept_cookies", "true")
    $("#cookies").hide('slow')

  $(".js-minus").click ->
    size = if $.cookie("font-size") == "bigger" then "big" else null
    $.cookie("font-size", size)
    $("body")
      .removeClass("big")
      .removeClass("bigger")
      .addClass(size)
    toggleFontResizeButtons()
    false

  toggleFontResizeButtons()

jQuery.initializer '#footer', ->
  # jquery footer cycle
  this.find(".partner-slider-1, .partner-slider-2, .partner-slider-3, .partner-slider-4").cycle
    fx: 'fade',
    speed:    0,
    timeout:  4000

jQuery.initializer '#menu', ->
  this.find('a.js-browse').click (e) ->
    e.preventDefault()
    filter = $("div#oz-browse-list")
    link = $(this)
    if link.hasClass "shown"
      filter.slideUp()
      link.removeClass "shown"
    else
      filter.slideDown()
      link.addClass("shown")

  this.find('a.sacral-options').click (e) ->
    e.preventDefault()
    filter = $("#menu div.sacral-categories")
    link = $(this)
    if link.hasClass "shown"
      filter.slideUp()
      link.removeClass "shown"
    else
      filter.slideDown()
      link.addClass("shown")