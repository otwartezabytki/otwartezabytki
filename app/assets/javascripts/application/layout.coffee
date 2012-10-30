jQuery ->
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

jQuery.initializer '#footer', ->
  # jquery footer cycle
  this.find(".partner-slider-1, .partner-slider-2, .partner-slider-3, .partner-slider-4").cycle
    fx: 'fade',
    speed:    0,
    timeout:  4000

jQuery.initializer '#menu', ->
  this.find('a.browse').click (e) ->
    e.preventDefault()
    filter = $("div#browse-list")
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