jQuery.initializer 'section.edit.events', ->
  $section = $(this)

  # don't await for photo if entered second time
  $.cookie('event_avaiting_photo', '')

  $('.add_event').click ->
    template = $($(this).data('template'))
    html = template.html()
    next_id = parseInt($('.sortable').children('li').length)#template.data('next-id'))
    template.data('next-id', next_id + 1)
    html = html.replace(/\[\d+\]/g, "[#{next_id}]")
    html = html.replace(/_\d+_/g, "_#{next_id}_")
    $(html).appendTo(template.parent())
    $section.find('.event-position').each (index) ->
      $(this).val(index + 1)
    template.parent().find('li:last input:first').focus()
    $('.fancybox-overlay').height($(document).height())
    false

  $(this).on 'click', '.add_photo, .edit_photo', ->
    if match = $(this).parent('li').attr('id')?.match(/\d+/)
      $.cookie('event_avaiting_photo', match[0])
      $("form.relic").submit()
    else
      alert('Musisz najpierw zapisać to wydarzenie.')

    false

  $(this).on 'click', '.remove_photo', ->
    $(this).parent('li').find('input[id$="photo_id"]').val('')
    $("form.relic").submit()
    false

  $(this).on 'click', '.remove_event', ->
    if confirm("Czy na pewno?")
      $(this).parents('.event:first').hide()
      $(this).parents('.event:first').find('input[name*="_destroy"]').val("1")
    false

  $(this).on 'click', '.save_item', (event) ->
    required = []
    $('.required').children().children().each ->
      if $(this).val() == ""
        required.push($(this)) 
      else if $(this).attr("id").split("_").last() == "date"
        console.log typeof(parseInt($(this).val()))
        required.push($(this)) if typeof(parseInt($(this).val())) != "number" || $(this).val().length < 4
    if required.length > 0
      event.preventDefault() 
      required.first().css('border-color', 'red')
      required.first().attr('placeholder', 'uzupełnij pole')