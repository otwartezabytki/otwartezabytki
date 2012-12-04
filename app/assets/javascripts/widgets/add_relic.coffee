#= require jquery
#= require vendor/jquery.fancybox
#= require libraries/post-message

window.oz_jQuery = jQuery.noConflict(true)
window.ozCom = null
oz_jQuery(document).on 'click', '#oz_add_relic_widget button', (e) ->
  e.preventDefault()
  oz_jQuery.fancybox
    padding: 3
    fitToView: true
    type: 'iframe'
    width: 980
    height: 780
    href: oz_jQuery(this).attr('src')
    afterLoad: ->
      unless window.ozCom
        window.ozCom = new OZ('oz-fancybox-iframe')
        window.ozCom.api 'on_iframe_init', (params) ->
          if oz_jQuery.fancybox.current.width != params.width || oz_jQuery.fancybox.current.height != params.height
            oz_jQuery.fancybox.current.width  = params.width
            oz_jQuery.fancybox.current.height = params.height
            oz_jQuery.fancybox.update()

    afterShow: ->
      oz_jQuery.fancybox.update()
