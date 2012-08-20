jQuery.initializer 'section.edit.photos', ->
  $section = $(this)
  $preview_placeholder = $section.find('.preview-placeholder')
  $progressbar = $section.find('.progressbar')
  $photo_hidden = $section.find('.photo.hidden')
  $photo_upload = $section.find(".photo_upload")
  $form = $section.find('form.relic')
  $cancel_upload = $section.find('.cancel_upload')
  $remove_photo = $section.find('.remove_photo')

  upload_spinner_opts = {
  lines: 8, length: 0, width: 6, radius: 10, rotate: 0, color: '#555', speed: 0.8, trail: 55,
  shadow: false, hwaccel: false, className: 'spinner', zIndex: 2e9, top: 46, left: 46
  }

  if $preview_placeholder.length
    spinner = new Spinner(upload_spinner_opts).spin($preview_placeholder[0])

  $progressbar.progressbar
    value: 0,
    change: (e) ->
      $(e.target).find('.value').text($progressbar.progressbar("value") + "%")

  photo_xhr = $(".photo_upload").fileupload
    type: "POST"
    dataType: "html"

    add: (e, data) ->
      $photo_hidden.removeClass('hidden')
      $photo_upload.hide()
      data.submit()

    submit: (e, data) ->
      data.formData = {}

    progressall: (e, data) ->
      progress = parseInt(data.loaded / data.total * 100, 10)
      $progressbar.progressbar("value", progress)

    done: (e, data) ->
      $new_section = $(data.result).find('section.edit')
      $section.replaceWith($new_section)
      $new_section.initialize()

  $cancel_upload.click ->
    photo_xhr.abort() if photo_xhr?

  $remove_photo.click ->
    $(this).parents('.photo:first').find('input[type="text"]').each ->
      $.cookie($(this).attr('id'), '')

  $form.submit ->
    if $section.find('#relic_license_agreement:checked').length == 0
      confirm('Ponieważ nie posiadasz praw do publikowania tych zdjęć, zostaną one usunięte. Kontynuować?')
    else
      true

  $section.on 'keyup', 'input.author', ->
    $input = $(this)
    $input.addClass('edited')
    $section.find("input.author:not(.edited)").each ->
      if $(this).hasClass('connected') || $(this).val().length == 0
        $(this).val($input.val()).addClass('connected')
        $(this).trigger('change')

  $section.on 'keyup', 'input.date_taken', ->
    $input = $(this)
    $input.addClass('edited')
    $section.find("input.date_taken:not(.edited)").each ->
      if $(this).hasClass('connected') || $(this).val().length == 0
        $(this).val($input.val()).addClass('connected')
        $(this).trigger('change')

  $section.on 'change', 'input.date_taken, input.author', ->
    $.cookie($(this).attr('id'), $(this).val())

  $section.find('input.date_taken, input.author').each ->
    $(this).val($.cookie($(this).attr('id'))) if $(this).val().length == 0 && $.cookie($(this).attr('id'))

  $("#photo_file").filestyle
    image: "/assets/photo-upload.png"
    imageheight: 25
    imagewidth: 154
    width: 154
