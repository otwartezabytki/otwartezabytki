#= require vendor/pl

jQuery.initializer 'section.edit.entries, section.edit.entries .entries-showcase', ->
  # in one line for easy removal using sed
  $(this).find('textarea.redactor:first').redactor focus: false, buttons: ['bold', 'italic', 'link', 'unorderedlist'], lang: 'pl'