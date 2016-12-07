set_contrast_cookie = (contrast) ->
  document.cookie = "contrast=#{contrast}; path=/;"

get_contrast_cookie = ->
  all_cookies = '; ' + document.cookie
  contr = all_cookies.split('; ' + 'contrast' + '=')
  if contr.length == 2
    cook = contr.pop().split(';').shift()
    console.log(cook)
    return cook

set_boy = ->
  console.log('weszlo')
  body = $('.oz-contrast-container')
  if body.hasClass 'oz-contr-black-on-yellow'
    body.removeClass 'oz-contr-black-on-yellow'
    set_contrast_cookie("normal")

  else
    if body.hasClass 'oz-contr-yellow-on-black'
      body.removeClass 'oz-contr-yellow-on-black'
    if body.hasClass 'oz-contr-white-on-black'
      body.removeClass 'oz-contr-white-on-black'
    body.addClass 'oz-contr-black-on-yellow'
    set_contrast_cookie('boy')
    console.log('wstawilo cookiesa')

set_wob = ->
  body = $('.oz-contrast-container')
  if body.hasClass 'oz-contr-white-on-black'
    body.removeClass 'oz-contr-white-on-black'
    set_contrast_cookie("normal")

  else
    if body.hasClass 'oz-contr-black-on-yellow'
      body.removeClass 'oz-contr-black-on-yellow'
    if body.hasClass 'oz-contr-yellow-on-black'
      body.removeClass 'oz-contr-yellow-on-black'
    body.addClass 'oz-contr-white-on-black'
    set_contrast_cookie('wob')

set_yob = ->
  body = $('.oz-contrast-container')
  if body.hasClass 'oz-contr-yellow-on-black'
    body.removeClass 'oz-contr-yellow-on-black'
    set_contrast_cookie("normal")

  else
    if body.hasClass 'oz-contr-white-on-black'
      body.removeClass 'oz-contr-white-on-black'
    if body.hasClass 'oz-contr-black-on-yellow'
      body.removeClass 'oz-contr-black-on-yellow'
    body.addClass 'oz-contr-yellow-on-black'
    set_contrast_cookie('yob')

$('.js-contr-black-on-yellow').click ->
  console.log('klik')
  set_boy()

$('.js-contr-white-on-black').click ->
  set_wob()

$('.js-contr-yellow-on-black').click ->
  console.log('klik')
  set_yob()

$('.js-contr-normal').click ->
  set_contrast_cookie("normal")
  body = $('.oz-contrast-container')
  if body.hasClass 'oz-contr-black-on-yellow'
    body.removeClass 'oz-contr-black-on-yellow'
  if body.hasClass 'oz-contr-yellow-on-black'
    body.removeClass 'oz-contr-yellow-on-black'
  if body.hasClass 'oz-contr-white-on-black'
    body.removeClass 'oz-contr-white-on-black'

$(document).ready ->
  contr = get_contrast_cookie()
  switch contr
    when 'boy'
      set_boy()
    when 'wob'
      set_wob()
    when 'yob'
      set_yob()
    else

