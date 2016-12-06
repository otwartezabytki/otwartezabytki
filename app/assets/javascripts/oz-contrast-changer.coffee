$('.js-change-contrast ').click ->
  body = $('body')
  if body.hasClass 'oz-contrast-changed'
    body.removeClass 'oz-contrast-changed'
  else
    body.addClass 'oz-contrast-changed'