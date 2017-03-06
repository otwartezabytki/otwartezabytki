#= require sugar
#= require_self
#= require_tree ./profile

@Profile ?= {}
@Profile.highlight_invalid_fields = (elem) ->
  elem.on 'click', '.save_item', (event) ->
    required = []
    $('.required').children().children().each ->
      if $(this).val() == ""
        required.push($(this))
      else if $(this).attr("id").split("_").last() == "date"
        required.push($(this)) if typeof(parseInt($(this).val())) != "number" || $(this).val().length < 4
    if required.length > 0
      event.preventDefault()
      required.each (element, index) ->
        element.css('border-color', 'red')
        element.attr('placeholder', 'pole nie może być puste')

prepare_alt = (item) ->
  return jQuery(item.description).text() + " " + item.alternate_text

jQuery.initializer 'section.show.photos', ->
  $section = this
  if slider = $section.find('#slider_mini')[0]
    photos = $(slider).data('photos')
    $(slider).jcarousel
      size: photos.length
      itemLoadCallback:
        onBeforeAnimation: (carousel, state) ->
          for i in [carousel.first..carousel.last]
            continue if carousel.has(i)
            break if i > photos.length
            item = photos[i - 1]
            carousel.add(i, "<a href='#{Routes.relic_photo_path(item.relic_id, item.id)}' data-maxi='#{item.file.maxi.url}' data-author='#{item.author}' data-alt='#{prepare_alt(item)}'><img src='#{item.file.mini.url}' width='80' height='60' alt='#{prepare_alt(item)}' /></a>")

    $(slider).on 'click', 'a[data-maxi]', ->
      $section.find('.main-photo span').html($(this).data('author'))
      $section.find('.main-photo img').attr
        src: $(this).data('maxi')
        alt: $(this).data('alt')
        # zakomentowane by nie wchodzic w konkretne zdjecie bezposrednio tylko w cala galerie, inaczej sa problemy miedzy kontrolerami
#      $section.find('.main-photo').attr('href', $(this).attr('href'))
      false

# calling it because photos_list has to be redirected to onclick event
bind_photo_change = (photos_list) ->
  $(document).on 'click', '.js-prev, .js-next', (e) ->
    e.preventDefault()
    link = $(this).attr('href')
    $(document).ajaxComplete ->
      photo_id = link.split('/').last()*1
      set_before_after(photo_id, photos_list)

on_carousel_photo_click = (photos_list) ->
  $(document).on 'click', '.jcarousel-skin-midi ul li a', (e) ->
    e.preventDefault()
    link = $(this).attr('href')
    $(document).ajaxComplete ->
      photo_id = link.split('/').last()*1
      set_before_after(photo_id, photos_list)

# function sets links to next and previous photo of relic
set_before_after = (photo_id, photos_list) ->
  #finding position of current photo
  pos = photos_list.map((photo) ->
    photo.id).indexOf((photo_id)
  )
  #checking, setting, showing, hiding link to previous photo
  if photos_list[pos-1]
    prev_link = "#{Routes.relic_photo_path(photos_list[pos-1].relic_id, photos_list[pos-1].id)}"
    $('.js-prev').attr('href', prev_link)
    $('.js-prev').show()
  else
    $('.js-prev').hide()

  if photos_list[pos+1]
    next_link = "#{Routes.relic_photo_path(photos_list[pos+1].relic_id, photos_list[pos+1].id)}"
    $('.js-next').attr('href', next_link)
    $('.js-next').show()
  else
    $('.js-next').hide()

jQuery.initializer 'section.show.photo', ->
  $section = this
  if slider = $section.find('#slider_midi')[0]
    $section.find('.js-prev').hide()
    $section.find('.js-next').hide()
    photos = $(slider).data('photos')
    start_photo_id = $('.photo-id').text()*1
    set_before_after(start_photo_id, photos)

    $(slider).jcarousel
      size: photos.length
      itemLoadCallback:
        onBeforeAnimation: (carousel, state) ->
          for i in [carousel.first..carousel.last]
            continue if carousel.has(i)
            break if i > photos.length
            item = photos[i - 1]
            carousel.add(i, "<a data-remote='true' href='#{Routes.relic_photo_path(item.relic_id, item.id)}' data-main='#{item.main}'><img src='#{item.file.midi.url}' alt='#{item.alternate_text}' /></a>")


    bind_photo_change(photos)
    on_carousel_photo_click(photos)

    $(document).keydown (e) ->
      $("a.js-next").trigger "click"  if e.which is 39

    $(document).keydown (e) ->
      $("a.js-prev").trigger "click"  if e.which is 37




$('body').on "click", ".close_popover", ->
  $("##{$(this).data('popover-id')}").popover('hide')
  false

jQuery.initializer 'body.relics.show', ->
  this.on 'click', 'a[href^="/relics/0/"]', (e) ->
    alert('To tylko podgląd. Nie możesz nic edytować.')
    false

jQuery.initializer 'section.edit', ->
  this.find('form').each ->
    $form = $(this)

    $form.on 'change', 'input', ->
      $form.data('changed', true)

    $form.on 'click', 'a.cancel', ->
      if $form.data('changed') || $form.find('input.error').length
        return confirm('Na pewno? Stracisz wprowadzone zmiany w tej sekcji.')
      else
        return true

jQuery.initializer 'section.show.subrelics', ->
  $(".subrelics-tree li a").click ->
    $('body').scrollTop(0)

jQuery.initializer 'section.show', ->
  this.find('a.fancybox').fancybox()

jQuery ->
  $('body').on 'click', '.flash-info-permament span', ->
    $.cookie('flash_hidden', true)

jQuery.initializer 'section.show.description', ->
  if $(".show.description .content").height() > 577
    $(".show.description .content").css
      height: 577
      overflow: "hidden"
    $(".show.description").append "<span id=\"toggle-read\">więcej</span>"


    $("#toggle-read").toggle (->
      $(this).parents(".show.description").find(".content").css
        height: "auto"

      # Hide the [...] when expanded
      $(this).text "mniej"
    ), ->
      $(this).parents(".show.description").find(".content").css
        height: 577

      $(this).text "więcej"
