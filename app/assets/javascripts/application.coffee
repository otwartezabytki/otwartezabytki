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
#= require_tree ./vendor
#= require js-routes
#= require twitter/bootstrap/bootstrap-tooltip
#= require twitter/bootstrap/bootstrap-popover
#= require variables
#= require_tree ./libraries
#= require profile
#= require_tree ./application

# FIX data-dismiss
$(document).on 'click', '[data-dismiss]', (e) ->
  e.preventDefault()
  el = $(this).attr('data-dismiss')
  $(".#{el}").slideUp()
