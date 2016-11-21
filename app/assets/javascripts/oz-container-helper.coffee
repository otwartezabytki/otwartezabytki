$(document).ready ->
  do_remove = $('.js-remove-their-container').css('content')
  if do_remove.length > 0
    $('.their-container').removeClass 'their-container'
  return

$(document).ready ->
  map = $('.oz-map-container')
  map_width = map.width()
  sidebar_height = $('.walking-guide__sidebar').height()
  console.log("wysokosc sidebau: " + sidebar_height)
  if $(document).width() < 992
    console.log("if")
    map.css 'height', "#{map_width}px"
  else
    console.log("else")
    map.css 'height', "#{sidebar_height}px"



jQuery.initializer '.js-remove-if-not-carousel', ->
  class_list = $('.js-remove-if-not-carousel')
  caro = $('.modal-body')
  if caro
    class_list.each ->
    cont = $(this).contents()
    $(this).replaceWith cont


