jQuery.initializer 'div.photo-attributes', ->
  $section = $(this)
  $preview_placeholder = $section.find('.preview-placeholder')
  $progressbar = $section.find('.progressbar')
  $photo_hidden = $section.find('.photo.hidden')
  $photo_upload = $section.find(".photo_upload")
  $form = $section.parents('form.relic')
  $cancel_upload = $section.find('.cancel_upload')
  $remove_photo = $section.find('.remove_photo')

  serialized_cookie = "photos_form_#{location.href.match(/relics\/(\d+)/)[1]}"

  serialize_form = ->
    $.cookie(serialized_cookie, $('form.relic').serialize())

  unserialize_form = ->
    if $.cookie(serialized_cookie)?
      $('form.relic').unserialize($.cookie(serialized_cookie), 'override-values': true)
      $.cookie(serialized_cookie, null)

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
    formData: [
      { name: 'authenticity_token', value: $form.find('input[name="authenticity_token"]').val() }
    ]

    add: (e, data) ->
      $photo_hidden.removeClass('hidden')
      $photo_upload.hide()
      data.submit()

    submit: (e, data) ->
      do serialize_form

    progressall: (e, data) ->
      progress = parseInt(data.loaded / data.total * 100, 10)
      $progressbar.progressbar("value", progress)

    done: (e, data) ->
      $new_section = $(data.result).find('div.photo-attributes')
      $section.replaceWith($new_section)
      $new_section.initialize()

  $cancel_upload.click ->
    photo_xhr.abort() if photo_xhr?

  $remove_photo.click serialize_form

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

  do unserialize_form

  $(this).find('textarea.redactor').redactor focus: false, buttons: ['bold', 'italic', 'link', 'unorderedlist'], lang: 'pl'

  image = if $('#photo_file').hasClass('first') then first_photo_upload else photo_upload
  $("#photo_file").filestyle
    image: image
    imageheight: 25
    imagewidth: 154
    width: 154
