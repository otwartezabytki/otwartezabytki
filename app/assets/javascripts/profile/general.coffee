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

jQuery.initializer 'section.edit.general', ->
  $("form.relic").submit ->
    $("section.edit").append('<div class="opacity"></div>').append '<div class="loading"><div class="inner"><div class="loader"><img src="/assets/fancybox/fancybox_loading.gif" alt="loading..." /></div></div></div>'
    submit = $(this).find(":submit").attr("value", "Zapisuję").css("padding", "0 31px")