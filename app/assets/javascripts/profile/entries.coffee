#= require vendor/pl
#= require vendor/jquery.masonry

jQuery.initializer 'section.edit.entries, section.edit.entries .entries-showcase', ->
  # in one line for easy removal using sed
  $(this).find('textarea.redactor:first').redactor focus: false, buttons: ['bold', 'italic', 'link', 'unorderedlist'], lang: 'pl'

makeTogglable = ($element) ->
  console.log $element

jQuery.initializer 'section.show.entries', ->
  entriesContainer = $('section.show.entries .content')
  entryContainerSelector = '.entry-container'
  entryContainer = entriesContainer.find(entryContainerSelector)

  entryContainer.each ->
    $entry = $(this)
    makeTogglable($entry) if $entry.find('.body').height() > 280

  entriesContainer.masonry
    itemSelector: entryContainerSelector
