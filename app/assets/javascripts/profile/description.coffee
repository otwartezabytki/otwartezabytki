jQuery.initializer 'section.edit.description', ->
  # in one line for easy removal using sed
  $(this).find('textarea.redactor').redactor focus: false, buttons: ['bold', 'italic', 'link', 'unorderedlist'], lang: 'pl'

  $("form.relic").submit ->
    $("section.edit").append('<div class="opacity"></div>').append '<div class="loading"><div class="inner"><div class="loader"><img src="/assets/fancybox/fancybox_loading.gif" alt="loading..." /></div></div></div>'
    submit = $(this).find(":submit").attr("value", "Zapisuję").css("padding", "0 31px")