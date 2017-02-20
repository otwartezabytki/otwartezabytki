$ ->
  $('.js-go-to-top').click (e) ->

    x = $('.oz-relic-desc-photos:first')

    $(document).ajaxSuccess ->
      setTimeout (->
        $('html, body').animate { scrollTop: x.offset().top }, 1000

      ), 300
  return