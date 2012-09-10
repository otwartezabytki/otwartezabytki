#= require jquery
#= require fancybox

$(document).on 'click', '#oz_add_relic_widget button', (e) ->
  e.preventDefault()
  $.fancybox
    padding: 3
    fitToView: true
    type: 'iframe'
    width: 980
    height: 780
    href: $(this).attr('src')
