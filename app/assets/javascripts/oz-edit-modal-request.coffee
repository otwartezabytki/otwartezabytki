$ ->
  $(document).on 'click', '.js-edit-relic-load-modal',  (e) ->
    e.preventDefault()
    _href = $(@).attr('href')
    $.ajax
      method: 'GET',
      dataType: 'html',
      url: _href
      success: (data) ->
        relic_modal = $('#edit-relic-modal') #get div of modal
        relic_modal_body = relic_modal.find('.modal-body') #get body of modal
        relic_modal_body.html(data) #put content in modal body
        relic_modal.modal() #show modal
        set_modal = $('.js-set-static-modal-width').css('content') #add static with for nonresponsive, remove it for location and photos
        if set_modal == undefined
          relic_modal.removeClass 'static-modal-width'
        else
          relic_modal.addClass 'static-modal-width'
        relic_modal.initialize() #initialize JQuery.initialize() functions