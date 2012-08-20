jQuery.initializer 'section.edit.description', ->
  $(this).find('textarea.redactor').redactor
    focus: false
    buttons: ['bold', 'italic', 'link', 'unorderedlist']
    lang: 'pl'