#= require jquery
#= require vendor/jquery.fancybox

window.oz_jQuery = jQuery.noConflict(true)
oz_jQuery(document).on 'click', '#oz_add_alert_widget button.create', (e) ->
  e.preventDefault()
  oz_jQuery.fancybox
    padding: 3
    fitToView: true
    type: 'iframe'
    width: 470
    height: 427
    href: oz_jQuery(this).attr('src')

oz_jQuery(document).on 'click', '#oz_add_alert_widget button.show', (e) ->
  e.preventDefault()
  window.open(oz_jQuery(this).attr('src'),'_blank')
  window.focus()

oz_jQuery(document).on 'click', '#oz_add_alert_widget button.none', (e) ->
  e.preventDefault()
