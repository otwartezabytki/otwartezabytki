jQuery.initializer 'section.edit', ->
  $section = this
  $nav = this.parent().children('nav')
  $section.find('form').each ->
    $form = $(this)
    serialized_form = $form.serialize()
    $form.data('serialized', serialized_form)

    $nav.find('a').click ->
      if serialized_form != $form.serialize()
        confirm("Jeśli wyjdziesz zmiany nie zostaną zapisane. Kontynuować?")
      else
        true

    $form.submit ->
      serialized_form = $(this).serialize()
      $form.data('serialized', serialized_form)
      true
