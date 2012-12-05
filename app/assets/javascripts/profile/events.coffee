jQuery.initializer 'section.edit.events', ->
  $section = $(this)

  # don't await for photo if entered second time
  $.cookie('event_avaiting_photo', '')

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
    template.parent().find('li:last input:first').focus()
    false

  $(this).on 'click', '.add_photo, .edit_photo', ->
    if match = $(this).parent('li').attr('id')?.match(/\d+/)
      $.cookie('event_avaiting_photo', match[0])
      $("form.relic").submit()
    else
      alert('Musisz najpierw zapisać to wydarzenie.')

    false

  $(this).on 'click', '.remove_event', ->
    if confirm("Czy na pewno?")
      $(this).parents('.event:first').hide()
      $(this).parents('.event:first').find('input[name*="_destroy"]').val("1")
    false

  $("form.relic").submit ->
    $("section.edit").append('<div class="opacity"></div>').append '<div class="loading"><div class="inner"><div class="loader"><img src="/assets/fancybox/fancybox_loading.gif" alt="loading..." /></div></div></div>'
    submit = $(this).find(":submit").attr("value", "Zapisuję").css("padding", "0 31px")