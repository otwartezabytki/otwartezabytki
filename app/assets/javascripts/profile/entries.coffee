jQuery.initializer 'section.edit.entries, section.edit.entries .entries-showcase', ->
  $(this).find('textarea.redactor:first').redactor
    focus: false
    buttons: ['bold', 'italic', 'link', 'unorderedlist']
    lang: 'pl'