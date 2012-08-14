#= require browser-update
#= require jquery
#= require jquery_ujs
#= require jquery.ui.core
#= require jquery.ui.widget
#= require jquery.ui.mouse
#= require jquery.ui.position
#= require jquery.ui.draggable
#= require jquery.ui.droppable
#= require jquery.ui.button
#= require jquery.ui.dialog
#= require jquery.ui.autocomplete
#= require jquery.ui.tabs
#= require jquery.ui.progressbar
#= require jquery.ui.sortable

#= require ./vendor/froogaloop
#= require ./vendor/jquery.cookie
#= require ./vendor/jquery.autocomplete-html
#= require ./vendor/jquery.cycle
#= require ./vendor/jquery.iframe-transport
#= require ./vendor/jquery.fileupload
#= require ./vendor/jquery.highlight-3
#= require ./vendor/jquery.transition.min
#= require ./vendor/jquery.jcarousel
#= require ./vendor/redactor
#= require ./vendor/select2
#= require ./vendor/spin.min
#= require js-routes

#= require_self
#= require profile


@marker_image_path = "<%= image_path('wizard-gps-circle-with-info.png') %>"
@small_marker_image_path = "<%= image_path('wizard-gps-circle.png') %>"
@geocoder_search_path = "/geocoder/search"
@photo_upload_button = "<%= image_path('upload-input.png') %>"

observed_selectors = {}

jQuery.initializer = (selector, callback) ->
  jQuery -> $(selector).each -> callback.call($(this))
  observed_selectors[selector] = [] if typeof observed_selectors[selector] == 'undefined'
  observed_selectors[selector].push(callback)

jQuery.fn.initialize = ->
  $.each observed_selectors, (selector, callbacks) =>
    this.each ->
      if $(this).is(selector)
        $.each callbacks, (_, callback) => callback.call($(this))

    $(this).find(selector).each ->
      $.each callbacks, (_, callback) => callback.call($(this))

poping_history = false
ajax_callback = (data, status, xhr) ->
  console.log(xhr.status)
  if xhr.getResponseHeader('Content-Type').match(/text\/html/)
    $parsed_data = $('<div>').append($(data))

    try_to_process_replace = (node) ->
      return unless node
      to_replace = $($(node).data('replace'))
      if to_replace.length
        to_replace.replaceWith(node)
        $(node).initialize()
      else
        try_to_process_replace($(node).parents('[data-replace]:first')[0])



    $parsed_data.find('[data-replace]').each ->
      unless $(this).find('[data-replace]').length
        try_to_process_replace(this)

    unless poping_history
      path = xhr.getResponseHeader('x-path')
      history.pushState { autoreload: true, path: path }, $parsed_data.find('title').text(), path
      poping_history = false

$(document).on 'ajax:success', 'form[data-remote], a[data-remote]', (e, data, status, xhr) ->
  ajax_callback(data, status, xhr)

$(window).load ->
  $(window).bind 'popstate', (event) ->
    console.log(event)
    if event.originalEvent.state?.autoreload
      poping_history = true
      path = event.originalEvent.state?.path
      $.ajax(path).success(ajax_callback).error(-> poping_history = false)

Search =
  init: ->
    $('body').on 'click', 'form.form-advance-search input[type=checkbox]', ->
      $(this).parents('form:first').submit()

    $('body').on 'change', 'form.form-advance-search select', ->
      $(this).parents('form:first').submit()

    $('body').on 'ajax:success', 'form.form-advance-search, nav.pagination, div.sidebar-nav, div.breadcrumb', (e, data) ->
      Search.render(data)
      # pushState
      history.pushState { searchreload: true }, $(data).find('title').text(), '/relics?' + $('form.form-advance-search').serialize()
  autocomplete: ->
    # autocomplete
    $input = $('input.autocomplete-q')
    if $input.length > 0
      $input.autocomplete(
        html: true,
        minLength: 2,
        source: (request, callback) ->
          $.getJSON "/relics/suggester", q: request.term, callback
        select: (event, ui) ->
          window.location = ui.item.path
      )

  render: (data) ->
    ['form.form-advance-search', '#main div.sidebar-nav', '#relics'].map (el) ->
      $(el).replaceWith $(data).find(el)
    Search.autocomplete()

# window
#window.onload = ->
#  window.onpopstate = (e) ->
#    location = history.location || document.location
#    if e.state?.searchreload or location.pathname.match(/\/?relics\/?$/)
#      $.get location, Search.render

@documentLoaded = ->

jQuery ->
  # search autoreload
  Search.init()
  Search.autocomplete()

  # highlight
  $highlightArea = $('div.search-results .relic')
  if $highlightArea.length > 0 and gon.highlightedTags
    for tag in gon.highlightedTags
      $highlightArea.highlight(tag)

  # font resize
  toggleFontResizeButtons = () ->
    $("span.plus, span.minus").removeClass("disabled")
    $("span.minus").addClass("disabled") unless $.cookie("font-size")
    $("span.plus").addClass("disabled") if $.cookie("font-size") == "bigger"

  $("span.plus").click ->
    size = if $.cookie("font-size") == null then "big" else "bigger"
    $.cookie("font-size", size)
    $("body")
      .removeClass("big")
      .removeClass("bigger")
      .addClass(size)
    toggleFontResizeButtons()
    false

  $("span.minus").click ->
    size = if $.cookie("font-size") == "bigger" then "big" else null
    $.cookie("font-size", size)
    $("body")
      .removeClass("big")
      .removeClass("bigger")
      .addClass(size)
    toggleFontResizeButtons()
    false

  toggleFontResizeButtons()

  # bootstrap
  # $("a[rel=popover]").popover()
  # $(".tooltip").tooltip()
  # $("a[rel=tooltip]").tooltip()

  #tabs
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

  window.documentLoaded(document)

  $('.alert').on 'click', 'a.close', ->
    $(this).parent('.alert').hide()
    false

if document.body.className.match(/thank_you/)
  window.fbAsyncInit = ->
    FB.init
      appId: "179800448818038"
      status: true
      cookie: true
      xfbml: true

    document.getElementById("share").onclick = ->
      obj =
        method: "feed"
        redirect_uri: "http://#{document.location.hostname}/facebook/share_close"
        link: "http://#{document.location.hostname}"
        name: "Otwarte Zabytki"
        caption: "społecznościowa akcja tworzenia bazy zabytków. Dołącz!"
        picture: "http://#{document.location.hostname}<%= image_path('logo-facebook.jpg') %>"
        display: "popup"

      FB.ui obj

  js = undefined
  id = "facebook-jssdk"
  ref = document.getElementsByTagName("script")[0]
  return if document.getElementById(id)
  js = document.createElement("script")
  js.id = id
  js.async = true
  js.src = "//connect.facebook.net/pl_PL/all.js"
  ref.parentNode.insertBefore js, ref