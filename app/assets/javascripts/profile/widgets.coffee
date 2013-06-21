# Add widget alert
# ----------------

$container = $('#add-widget-alert')
$widget_output = $container.find('.add-alert-widget-output').first().hide()
widget_container_id = 'add-alert-widget-content'
animation_duration = 1000

$new = (tag) ->
  $(document.createElement tag)

createDynamicFrame = (contentText, $parent, callback) ->
  try
    $iframe = $new('iframe').attr(
      src: 'about:blank'
      class: widget_container_id
      id: widget_container_id
    ).prependTo($parent)

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
  $widget_output.show(animation_duration)
  console.log $event

$.initializer $container.find('.add-alert-widget-button'), ->
  @on 'click', ($event) ->
    $event.preventDefault()
    return unless $widget_output.length and !$('#' + widget_container_id).length

    $element = $($event.target)
    $placeholder = $element.parent '.placeholder'
    $placeholder.hide(animation_duration) if $placeholder

    source = $element.data('widget-source').trim()
    return unless source

    createDynamicFrame source, $widget_output, handleFrameLoaded
