# Add widget alert
# ----------------

widget_container_id = 'add-alert-widget-content'
animation_duration = 1000

$container = $('#add-widget-alert')
$widget_container = $('.' + widget_container_id).first()
$widget_output = $container.find('.add-alert-widget-output').first()
$widget_trigger = $container.find('.add-alert-widget-button')

$widget_loading_information = $container.find('.add-alert-widget-information--loading')
$widget_error_information = $container.find('.add-alert-widget-information--error').hide()

showError = ->
  $widget_error_information.show(animation_duration)

createDynamicFrame = (contentText, $parent, callback) ->
  try
    $iframe = $(document.createElement 'iframe').attr(
      src: 'about:blank'
      id: widget_container_id
    ).hide().appendTo($parent).on 'error', showError

    if typeof callback is 'function'
      $iframe.on 'load', callback

    iframe_document = $iframe.get(0).contentWindow.document
    iframe_document.open 'text/html', 'replace'
    iframe_document.write contentText
    iframe_document.close()
  catch exception
    console.log exception
    return false
  true

handleFrameLoaded = ($event) ->
  $widget_loading_information.hide(animation_duration)
  $($event.target).show(animation_duration)

$.initializer $widget_trigger, ->
  @on 'click', ($event) ->
    $event.preventDefault()
    $widget_output.show(animation_duration)
    return showError() unless $widget_output.length and !$('#' + widget_container_id).length

    $element = $($event.target)
    $placeholder = $element.parent '.placeholder'
    $placeholder.hide(animation_duration) if $placeholder

    source = $element.data('widget-source').trim()
    unless source and createDynamicFrame(source, $widget_container, handleFrameLoaded)
      showError()
