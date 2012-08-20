jQuery.initializer 'section.show.general', ->
  $(this).find("#relic_location_popover").popover
    title: -> $("##{$(this).data("title-id")}").html()
    content: -> $("##{$(this).data("content-id")}").html()
    delay: 100000

  $(this).find("#relic_location_popover").click ->
    $(this).popover('toggle')
    false