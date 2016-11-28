#function to remove nonbootstrap container class
$(document).ready ->
  if $('.js-remove-their-container').length > 0
    $('.their-container').removeClass 'their-container'
  return

$(document).ready ->
  map = $('.oz-map-container')
  map_width = map.width()
  sidebar_height = $('.walking-guide__sidebar').height()
  if $(document).width() < 992
    map.css 'height', "#{map_width}px"
  else
    map.css 'height', "#{sidebar_height}px"

jQuery.initializer '.js-remove-if-not-carousel', ->
  class_list = $('.js-remove-if-not-carousel')
  caro = $('.modal-body')
  if caro
    class_list.each ->
    cont = $(this).contents()
    $(this).replaceWith cont


