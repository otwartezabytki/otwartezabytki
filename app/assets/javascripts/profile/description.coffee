jQuery.initializer 'section.edit.description', ->
  # in one line for easy removal using sed
  $(this).find('textarea.redactor').redactor focus: false, buttons: ['bold', 'italic', 'link', 'unorderedlist'], lang: 'pl'