jQuery.initializer 'section.edit.links', ->
  $section = $(this)

  next_id = parseInt($section.find('form.relic').data('next-id'))
  $(this).on 'click', '.add_link', ->
    template = $($(this).data('template'))
    html = template.html()
    html = html.replace(/\[\d+\]/g, "[#{next_id}]")
    html = html.replace(/_\d+_/g, "_#{next_id}_")
    $(html).appendTo(template.parent())
    $section.find('.link-position').each (index) ->
      $(this).val(index + 1)
    template.parents('.links_container:first').show()
    next_id += 1
    false

  $(this).on 'click', '.remove_link', ->
    if confirm("Czy na pewno?")
      $(this).parents('.link:first').hide()
      $(this).parents('.link:first').find('input[name*="_destroy"]').val("1")
      $(this).parents('.links_container:first').hide() if $(this).parents('.links_container:first').find('.link:visible').length == 0
    false

  $(this).find('ol.sortable').sortable
    axis: 'y'
    update: ->
      $section.find('.link-position').each (index) ->
        $(this).val(index + 1)