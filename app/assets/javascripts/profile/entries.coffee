#= require vendor/pl

jQuery.initializer 'section.edit.entries, section.edit.entries .entries-showcase', ->
  # in one line for easy removal using sed
  $(this).find('textarea.redactor:first').redactor focus: false, buttons: ['bold', 'italic', 'link', 'unorderedlist'], lang: 'pl'

jQuery.initializer 'section.edit.entries', ->
  $("form.relic").submit ->
    $("section.edit").append('<div class="opacity"></div>').append '<div class="loading"><div class="inner"><div class="loader"><img src="/assets/fancybox/fancybox_loading.gif" alt="loading..." /></div></div></div>'
    submit = $(this).find(":submit").attr("value", "Zapisuję").css("padding", "0 31px")