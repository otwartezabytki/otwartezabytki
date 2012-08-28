jQuery.initializer 'section.edit.events', ->
  $section = $(this)

  $('.add_event').click ->
    template = $($(this).data('template'))
    html = template.html()
    next_id = parseInt(template.data('next-id'))
    template.data('next-id', next_id + 1)
    html = html.replace(/\[\d+\]/g, "[#{next_id}]")
    html = html.replace(/_\d+_/g, "_#{next_id}_")
    $(html).appendTo(template.parent())
    $section.find('.event-position').each (index) ->
      $(this).val(index + 1)
    false

  $(this).on 'click', '.remove_event', ->
    if confirm("Czy na pewno?")
      $(this).parents('.event:first').hide()
      $(this).parents('.event:first').find('input[name*="_destroy"]').val("1")
    false