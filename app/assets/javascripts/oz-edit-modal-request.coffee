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
        relic_modal.modal({backdrop: true, keyboard: true}) #show modal
        set_modal = $('.js-set-static-modal-width').css('content') #add static with for nonresponsive, remove it for location and photos
        if set_modal == undefined
          relic_modal.removeClass 'static-modal-width'
        else
          relic_modal.addClass 'static-modal-width'
        relic_modal.initialize() #initialize JQuery.initializer() functions

jQuery.initializer '.js-close-edit-relic', ->
  this.on 'click', ->
    $('#edit-relic-modal').modal('hide')
    location.reload(true)

$('#edit-relic-modal').on 'hidden.bs.modal', ->
  $.ajax(window.location.href).success(ajax_callback).complete(-> popping_state = false)

$('#edit-relic-modal').on 'hide.bs.modal', ->
  $form = $('.modal-body form:first')
  if serialized_data = $form.data('serialized')
    if serialized_data != $form.serialize()
      return confirm("Jeśli wyjdziesz zmiany nie zostaną zapisane. Kontynuować?")

  return true
$(document).ready ->
  jQuery ($) ->
    $(document).ajaxStop ->
      $('#fancybox_loader_container').hide()
      return
    $(document).ajaxStart ->
      $('#fancybox_loader_container').show()
      return
    return