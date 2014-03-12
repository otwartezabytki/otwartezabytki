# ----------------
# Add widget alert
# ----------------

jQuery.initializer '#add-widget-alert .add-alert-widget-button', ->
  widget_container_id = 'add-alert-widget-content'

  $container         = $('#add-widget-alert')
  $widget_container  = $('.' + widget_container_id).first()
  $widget_output     = $container.find('.add-alert-widget-output').first()

  $widget_loading_information = $container.find('.add-alert-widget-information--loading')
  $widget_error_information   = $container.find('.add-alert-widget-information--error').hide()
  $widget_generated_content   = $container.find('#oz_add_alert_widget').hide()

  @on 'click', ($event) ->
    $event.preventDefault()
    $widget_output.show(0).addClass 'visible'
    $element = $(this)

    # Generate widget
    s        = document.createElement('script')
    s.type   = 'text/javascript'
    s.async  = true
    s.src    = $(this).data('widget-src')
    s.onload = ($event) ->
      setTimeout ->
        $widget_loading_information.hide()
        $widget_generated_content.show(1000)
      , 1000

    x = document.getElementsByTagName('script')[0]
    x.parentNode.insertBefore(s, x)

    $placeholder = $element.parent '.placeholder'
    $placeholder.hide() if $placeholder

    # Handle selectable code
    $widget_output.find('.selectable-code').each ->
      $(this).on 'click', ($event) ->
        element = $event.target
        element.focus()
        element.select()
