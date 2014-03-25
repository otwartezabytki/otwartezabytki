#= require jquery
#= require vendor/jquery.fancybox
#= require libraries/post-message

window.oz_jQuery = jQuery.noConflict(true)
window.ozCom     = new OZ('oz-fancybox-iframe')

alertWidgetId = '#oz_add_alert_widget'
refreshAlertBox = ->
  refreshUrl = oz_jQuery("#{alertWidgetId} .widget-box[src]").attr('src')
  oz_jQuery.get refreshUrl, (response) ->
    oz_jQuery(alertWidgetId).html(response)

oz_jQuery(document).on 'click', "#{alertWidgetId} button.create", (e) ->
  e.preventDefault()

  oz_jQuery.fancybox
    padding: 3
    type: 'iframe'
    autoSize: false
    iframe :
      scrolling : 'no'
      preload   : true
    href: oz_jQuery(this).attr('src')
    onIframeLoading: () ->
      window.ozCom.api 'on_iframe_init', (params) ->
        refreshAlertBox()
        fancyboxInstance = oz_jQuery.fancybox.coming || oz_jQuery.fancybox.current
        if fancyboxInstance and (fancyboxInstance.width != params.width or fancyboxInstance.height != params.height)
          fancyboxInstance.width  = params.width
          fancyboxInstance.height = params.height
          oz_jQuery.fancybox.update()
    afterLoad: () ->
      oz_jQuery.fancybox.update()
    afterShow: () ->
      oz_jQuery.fancybox.update()

oz_jQuery(document).on 'click', "#{alertWidgetId} button.show", (e) ->
  e.preventDefault()
  window.open(oz_jQuery(this).attr('src'),'_blank')
  window.focus()

oz_jQuery(document).on 'click', "#{alertWidgetId} button.none", (e) ->
  e.preventDefault()
