$(document).ready ->
  do_remove = $('.js-remove-their-container').css('content')
  if do_remove.length > 0
    $('.their-container').removeClass 'their-container'
  return

jQuery.initializer '.js-remove-if-not-carousel', ->
  class_list = $('.js-remove-if-not-carousel')
  caro = $('.modal-body')
  if caro
    class_list.each ->
    cont = $(this).contents()
    $(this).replaceWith cont


