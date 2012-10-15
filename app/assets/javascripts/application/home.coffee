jQuery.initializer 'body.show.resource_home', ->
  show_tab = (panel) ->
    unless $(panel).find('iframe').length
      spinner = new Spinner(
        lines: 13
        length: 7
        width: 4
        radius: 10
        rotate: 0
        color: '#000'
        speed: 1
        trail: 60
        shadow: false
        hwaccel: false
        className: 'spinner'
        zIndex: 2e9
        top: 88
        left: 180
      ).spin(panel)
      $(panel).append($(panel).find('script').html())
      $(panel).find('iframe').load ->
        $(this).css(opacity: 1)
        spinner.stop()

  stop_videos = ->
    $('#tabs iframe').each ->
      $f(this).api('pause')

  $("#tabs").tabs
    create: (enevt, ui) ->
      $('#tabs img').css('display', 'block')
    select: (event, ui) ->
      do stop_videos
      show_tab(ui.panel)

  $(window).load ->
    show_tab($('#tabs-1')[0])

  # jquery footer cycle
  jQuery(".partner-slider-1, .partner-slider-2, .partner-slider-3").cycle({
    fx: 'fade',
    speed:    0,
    timeout:  4000
  })

  $('#map-poland').cssMap({'size' : 340})