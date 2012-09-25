#= require jquery
#= require vendor/jquery.fancybox
#= require libraries/post-message

window.oz_jQuery = jQuery.noConflict(true)
window.ozCom = null

oz_jQuery(document).on 'click', '#oz_add_alert_widget button.create', (e) ->
  e.preventDefault()

  oz_jQuery.fancybox
    padding: 3
    type: 'iframe'
    autoSize: false
    href: oz_jQuery(this).attr('src')
    afterLoad: ->
      unless window.ozCom
        window.ozCom = new OZ('oz-fancybox-iframe')
        window.ozCom.api 'on_iframe_init', (params) ->
          console.log "doc.params", params
          if oz_jQuery.fancybox.current.width != params.width
            oz_jQuery.fancybox.current.width  = params.width
          #   oz_jQuery.fancybox.current.height = params.height
          #   console.log 'fancybox update'
            oz_jQuery.fancybox.update()

    afterShow: ->
      console.log 'afterShow'
      oz_jQuery.fancybox.update()

oz_jQuery(document).on 'click', '#oz_add_alert_widget button.show', (e) ->
  e.preventDefault()
  window.open(oz_jQuery(this).attr('src'),'_blank')
  window.focus()

oz_jQuery(document).on 'click', '#oz_add_alert_widget button.none', (e) ->
  e.preventDefault()
