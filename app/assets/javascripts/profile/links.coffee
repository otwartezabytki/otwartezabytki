jQuery.initializer 'section.edit.links', ->
  $section = $(this)

  $(this).on 'click', '.add_link', ->
    template = $($(this).data('template'))
    html = template.html()
    next_id = parseInt(template.data('next-id'))
    template.data('next-id', next_id + 1)
    html = html.replace(/\[\d+\]/g, "[#{next_id}]")
    html = html.replace(/_\d+_/g, "_#{next_id}_")
    $(html).appendTo(template.parent())
    $section.find('.link-position').each (index) ->
      $(this).val(index + 1)
    $('#links_container').show()
    false

  $(this).on 'click', '.remove_link', ->
    if confirm("Czy na pewno?")
      $(this).parents('.link:first').hide()
      $(this).parents('.link:first').find('input[name*="_destroy"]').val("1")
      $('#links_container').hide() if $('.link:visible').length == 0
    false

  $(this).find('ol.sortable').sortable
    axis: 'y'
    update: ->
      $section.find('.link-position').each (index) ->
        $(this).val(index + 1)