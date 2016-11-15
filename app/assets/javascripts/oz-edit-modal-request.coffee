$ ->
  $(document).on 'click', '.js-edit-relic-load-modal',  (e) ->
    e.preventDefault()
    _href = $(@).attr('href')
    $.ajax
      method: 'GET',
      dataType: 'html',
      url: _href
      success: (data) ->
        relic_modal = $('#edit-relic-modal')
        relic_modal.html(data)
        relic_modal.modal()
        set_modal = $('.js-set-static-modal-width').css('content')
        if set_modal == undefined
          relic_modal.removeClass 'static-modal-width'
        else
          relic_modal.addClass 'static-modal-width'
        relic_modal.initialize()