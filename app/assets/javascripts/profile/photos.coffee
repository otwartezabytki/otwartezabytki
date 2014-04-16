jQuery.initializer 'div.photo-attributes', ->
  $section = $(this)
  $preview_placeholder = $section.find('.preview-placeholder')
  $progressbar = $section.find('.progressbar')
  $photo_hidden = $section.find('.photo.hidden')
  $photo_upload = $section.find(".photo-upload")
  $form = $section.parents('form.relic')
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
    formData: [
      { name: 'authenticity_token', value: $form.find('input[name="authenticity_token"]').val() }
    ]

    add: (e, data) ->
      $photo_hidden.removeClass('hidden')
      $photo_upload.hide()
      jqXHR = data.submit()
      $cancel_upload.click (e) ->
        console.log jqXHR
        jqXHR.abort()

    progressall: (e, data) ->
      progress = parseInt(data.loaded / data.total * 100, 10)
      $progressbar.progressbar("value", progress)
      if data.loaded == data.total
        $cancel_upload.hide()

    done: (e, data) ->
      $new_section = $(data.result).find('div.photo-attributes')
      $section.replaceWith($new_section)
      $new_section.initialize()

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

  $(this).find('textarea.redactor').redactor focus: false, buttons: ['bold', 'italic', 'link', 'unorderedlist'], lang: 'pl'
  # fix redactor to trigger change event on textarea
  $section.on 'input keydown', '.redactor_editor', ->
    $(this).siblings('textarea').trigger('change')

  # fix for serialization problem
  ['author', 'date_taken', 'description', 'alternate_text'].each (attrClass) ->
    find_photo_id = (el) ->
      $(el).parents('.photo:first').attr('id')

    $section.on 'change', "input.#{attrClass}, textarea.#{attrClass}", ->
      photo_id = find_photo_id(this)
      $.cookie("#{photo_id}_#{attrClass}", $(this).val())

    $section.find("input.#{attrClass}, textarea.#{attrClass}").each ->
      photo_id = find_photo_id(this)
      value_from_cookie = $.cookie("#{photo_id}_#{attrClass}")
      $(this).val(value_from_cookie) if $(this).val().length == 0 && value_from_cookie
