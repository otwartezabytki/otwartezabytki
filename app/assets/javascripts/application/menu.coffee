# Adjusts main menu’s font size when it doesn’t fit in one line

do ($ = jQuery) ->
  $ ->
    menu  = $('#page-menu')
    items = menu.children()
    firstItem = items.first()
    lastItem  = items.last()

    areAllItemsOnTheSameLine = ->
      firstItem.offset().top is lastItem.offset().top

    unless areAllItemsOnTheSameLine()
      ajustFontSize = ->
        classNames = ['smaller-14', 'smaller-13', 'smaller-12', 'smaller-11']
        classNamesString = classNames.join(' ')

        for className in classNames
          if areAllItemsOnTheSameLine()
            break

          menu.removeClass(classNamesString)
          menu.addClass(className)

      ajustFontSize()
      $(window).load ajustFontSize
