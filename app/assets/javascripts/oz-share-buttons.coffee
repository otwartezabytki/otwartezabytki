$ ->
  $('.js-walking-guide-mail')[0].href = 'mailto:?subject=&body=' +  encodeURIComponent(window.location.href)
  $('.js-walking-guide-share')[0].href = 'http://www.facebook.com/sharer/sharer.php?sdk=joey&u=' + encodeURIComponent(window.location.href) + '%2F&display=popup&ref=plugin&src=share_button'
  $('.js-walking-guide-share').unbind('click').bind 'click', ->
    window.open($('.js-walking-guide-share')[0].href)
    return false