jQuery.initializer 'section.edit.links', ->
  $section = $(this)

  next_id = parseInt($section.find('form.relic').data('next-id'))

  $section.on 'click', '.add_link', ->
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

  $section.on 'click', '.remove_link', ->
    if confirm("Czy na pewno?")
      $(this).parents('.link:first').hide()
      $(this).parents('.link:first').find('input[name*="_destroy"]').val("1")
      if $(this).parents('.links_container:first').find('.link:visible').length == 0
        $(this).parents('.links_container:first').hide()
      $sortable.refresh()
    false

  $sortable = $section.find('ol.sortable').sortable
    axis: 'y'
    update: ->
      $section.find('.link-position').each (index) ->
        $(this).val(index + 1)
  .data('sortable')

  $("form.relic").submit ->
    $("section.edit").append('<div class="opacity"></div>').append '<div class="loading"><div class="inner"><div class="loader"><img src="/assets/fancybox/fancybox_loading.gif" alt="loading..." /></div></div></div>'
    submit = $(this).find(":submit").attr("value", "Zapisuję").css("padding", "0 31px")