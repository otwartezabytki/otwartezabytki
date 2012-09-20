#= require jquery
#= require vendor/jquery.fancybox

window.oz_jQuery = jQuery.noConflict(true)
oz_jQuery(document).on 'click', '#oz_add_relic_widget button', (e) ->
  e.preventDefault()
  oz_jQuery.fancybox
    padding: 3
    fitToView: true
    type: 'iframe'
    width: 980
    height: 780
    href: oz_jQuery(this).attr('src')
