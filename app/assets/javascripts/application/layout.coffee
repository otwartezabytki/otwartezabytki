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