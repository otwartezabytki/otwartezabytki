jQuery.initializer 'section.edit.documents', ->
  $section = $(this)
  $preview_placeholder = $section.find('.preview-placeholder')
  $progressbar = $section.find('.progressbar')
  $document_hidden = $section.find('.document.hidden')
  $document_upload = $section.find(".document_upload")
  $form = $section.find('form.relic')
  $cancel_upload = $section.find('.cancel_upload')
  $remove_document = $section.find('.remove_document')

  upload_spinner_opts = {
  lines: 8, length: 0, width: 6, radius: 10, rotate: 0, color: '#555', speed: 0.8, trail: 55,
  shadow: false, hwaccel: false, className: 'spinner', zIndex: 2e9, top: 16, left: 16
  }

  if $preview_placeholder.length
    spinner = new Spinner(upload_spinner_opts).spin($preview_placeholder[0])

  $progressbar.progressbar
    value: 0,
    change: (e) ->
      $(e.target).find('.value').text($progressbar.progressbar("value") + "%")

  document_xhr = $(".document_upload").fileupload
    type: "POST"
    dataType: "html"
    formData: [
      { name: 'authenticity_token', value: $form.find('input[name="authenticity_token"]').val() }
    ]

    add: (e, data) ->
      $document_hidden.removeClass('hidden')
      $document_upload.hide()
      data.submit()

    submit: (e, data) ->

    progressall: (e, data) ->
      progress = parseInt(data.loaded / data.total * 100, 10)
      $progressbar.progressbar("value", progress)

    done: (e, data) ->
      $new_section = $(data.result).find('section.edit')
      $section.replaceWith($new_section)
      $new_section.initialize()

  $cancel_upload.click ->
    document_xhr.abort() if document_xhr?

  $remove_document.click ->
    $(this).parents('.document:first').find('input[type="text"]').each ->
      $.cookie($(this).attr('id'), '')

  $section.on 'change', 'input.name, input.description', ->
    $.cookie($(this).attr('id'), $(this).val())

  $section.find('input.name, input.description').each ->
    $(this).val($.cookie($(this).attr('id'))) if $(this).val().length == 0 && $.cookie($(this).attr('id'))

  $("#document_file").filestyle
    image: "/assets/file-upload.png"
    imageheight: 25
    imagewidth: 134
    width: 134
