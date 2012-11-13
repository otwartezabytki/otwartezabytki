$.ajaxSetup(dataType: 'html')

observed_selectors = {}

jQuery.initializer = (selector, callback) ->
  jQuery -> $(selector).each -> callback.call($(this))
  observed_selectors[selector] = [] if typeof observed_selectors[selector] == 'undefined'
  observed_selectors[selector].push(callback)

jQuery.fn.initialize = ->
  $.each observed_selectors, (selector, callbacks) =>
    this.each ->
      if $(this).is(selector)
        $.each callbacks, (_, callback) => callback.call($(this))

    $(this).find(selector).each ->
    $(this).find(selector).each ->
      $.each callbacks, (_, callback) => callback.call($(this))

popping_state = false
last_xhr = null
ajax_callback = (data, status, xhr) ->
  if xhr.getResponseHeader('Content-Type').match(/text\/javascript/)
    jQuery.globalEval data
  else if xhr.getResponseHeader('Content-Type').match(/text\/html/)
    last_xhr = xhr
    window.map = null # hack for location view...
    $parsed_data = $('<div>').append($(data))

    float_fancybox = last_xhr.getResponseHeader('x-float')?

    try # gon script hack
      jQuery.globalEval $parsed_data.find('script:contains(window.gon)').text()

    show_fancybox = (node) ->
      window.before_fancybox_url = document.location.href
      $.fancybox $(node),
        padding: 3
        fitToView: float_fancybox
        fixed: float_fancybox
        scrolling: if float_fancybox then 'auto' else 'no'
        autoCenter: float_fancybox
        autoHeight: !float_fancybox
        afterShow: ->
          $.fancybox.wrap.bind 'onReset', (e) ->
            $('body > .main-container:last').remove()
        beforeClose: ->
          $form = $('.fancybox-wrap form:first')
          if serialized_data = $form.data('serialized')
            if serialized_data != $form.serialize()
              return confirm("Jeśli wyjdziesz zmiany nie zostaną zapisane. Kontynuować?")

          return true
        afterClose: ->
          history.pushState { autoreload: true, path: window.before_fancybox_url }, $('title').text(), window.before_fancybox_url
          if last_xhr.getResponseHeader('x-logged')? && $('body').data('logged')? && $('body').data('logged').toString() != last_xhr.getResponseHeader('x-logged').toString()
            window.location.href = window.location.pathname

    try_to_process_replace = (node) ->
      # if node to replace is not found, redirect
      window.location.href = xhr.getResponseHeader('x-path') unless node?

      data_replace_parent = $(node).parents('[data-replace]:first')[0]

      if $('#fancybox').length && xhr.getResponseHeader('x-fancybox')
        to_replace = $('.fancybox-wrap').find($(node).data('replace'))

        if to_replace.length
          to_replace.replaceWith(node)
          $(node).initialize()
        else
          if data_replace_parent && !$(node).is('[data-fancybox]')
            try_to_process_replace(data_replace_parent)
          else
            show_fancybox(node)
            $(node).initialize()
      else if last_xhr.getResponseHeader('x-logged')? && $('body').data('logged')? && $('body').data('logged').toString() != last_xhr.getResponseHeader('x-logged').toString()
          window.location.href = window.location.pathname
      else
        to_replace = $('#root').find($(node).data('replace'))
        if to_replace.length
          to_replace.replaceWith(node)
          $.fancybox.close() if $.fancybox
          $(node).initialize()
        else
          try_to_process_replace(data_replace_parent)

    if $parsed_data.find('[data-replace]').length
      $parsed_data.find('[data-replace]').each ->
        unless $(this).find('[data-replace]').length
          try_to_process_replace(this)
    else
      window.location.href = xhr.getResponseHeader('x-path')

    unless popping_state
      path = xhr.getResponseHeader('x-path')
      history.pushState { autoreload: true, path: path }, $parsed_data.find('title').text(), xhr.getResponseHeader('x-path')

$(document).on 'ajax:success', 'form[data-remote], a[data-remote]', (e, data, status, xhr) ->
  popping_state = false
  ajax_callback.call(this, data, status, xhr)
  e.stopPropagation()

$(document).on 'ajax:error', 'form[data-remote], a[data-remote]', (e, xhr, status, error) ->
  popping_state = false
  window.location.href = Routes.new_user_session_path() if error == "Unauthorized"
  e.stopPropagation()

$(window).load ->
  setTimeout ->
    $(window).bind 'popstate', (event) ->
      state = event.originalEvent.state
      popping_state = true
      if state && state.autoreload
        $.ajax(state.path).success(ajax_callback).complete(-> popping_state = false)
      else
        $.ajax(document.location).success(ajax_callback).complete(-> popping_state = false)
  , 500