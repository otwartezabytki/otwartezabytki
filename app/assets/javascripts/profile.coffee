jQuery ->
  $('section.description').on 'click', 'a[data-ajax=true]', ->
    jQuery.get this.href, (data) ->
      $('section.description').html($(data).find('section.description').html())
      window.documentLoaded($('section.description'))

    false

  $('section.description').on 'ajax:success', 'form', (event, data) ->
    $('section.description').html($(data).find('section.description').html())
    window.documentLoaded($('section.description'))