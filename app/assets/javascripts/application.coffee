# TODO: move all vendor requires to files where they're actually used
#= require vendor/browser-update
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
#= require ./vendor/jquery.filestyle
#= require ./vendor/jquery.highlight-3
#= require ./vendor/jquery.transition.min
#= require ./vendor/jquery.jcarousel
#= require ./vendor/jquery.tinyscrollbar.min
#= require ./vendor/redactor
#= require ./vendor/select2
#= require ./vendor/spin.min
#= require js-routes
#= require twitter/bootstrap
#= require fancybox

#= require variables
#= require_tree ./libraries
#= require_tree ./application
#= require profile

# TEMP

jQuery.initializer 'body', ->
  $input = this.find("input.autocomplete-polish-place")
  return false unless $input.length > 0
  $ul = $('div.places-wrapper ul')
  $input.autocomplete(
    minLength: 2,
    source: (request, callback) ->
      $.getJSON "/suggester/place_from_poland", q: request.term, callback
  )
  $input.data("autocomplete")._renderMenu = (ul, items) ->
    $ul.text('')
    for item in items
      @_renderItem ul, item
  $input.data("autocomplete")._renderItem = (ul, item ) ->
    data = [item.voivodeship_name, item.district_name, item.commune_name]
    data.push "<strong>#{item.name}</strong>"
    $(
      "<li>#{data.join(' > ')}
       <a data-remote=true href='/relics/build/#{item.location}/area'>wybieram &raquo;</a> </li>"
    ).appendTo($ul)