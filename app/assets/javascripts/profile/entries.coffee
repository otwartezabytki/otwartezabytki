#= require vendor/pl
#= require vendor/jquery.masonry

jQuery.initializer 'section.edit.entries, section.edit.entries .entries-showcase', ->
  # in one line for easy removal using sed
  $(this).find('textarea.redactor:first').redactor focus: false, buttons: ['bold', 'italic', 'link', 'unorderedlist'], lang: 'pl'

jQuery.initializer 'section.show.entries', ->
  lessClass = 'less'
  lessText = 'Mniej'
  moreText = 'Więcej…'

  entriesContainer = $('section.show.entries .content')
  entryContainerSelector = '.entry-container'
  entryContainer = entriesContainer.find(entryContainerSelector)

  unless entryContainer.length > 2
    applyLayout = updateLayout = ->
  else
    applyLayout = ->
      entriesContainer.masonry
        isAnimated: true
        itemSelector: entryContainerSelector
        animationOptions:
          duration: 400
    updateLayout = ->
      entriesContainer.masonry 'reload'

  makeTogglable = ($element) ->
    $element.addClass 'togglable ' + lessClass
    $toggle = $('<div class="toggle"></div>')
    $element.append $toggle.text(moreText)

    $toggle.on 'click', ->
      if $element.hasClass lessClass
        $toggle.text lessText
      else
        $toggle.text moreText

      $element.toggleClass lessClass
      updateLayout()

  entryContainer.each ->
    $entry = $(this).find('.entry')
    makeTogglable($entry) if $entry.find('.body').height() > 280

  applyLayout()
