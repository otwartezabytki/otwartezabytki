jQuery.initializer '.edit_widget.map_search', ->
  console.log('initializer')
  oz = new OZ('oz_map_search')
  oz.api 'on_params_changed', (params) ->
    $('#widget_map_search_api_params').val(JSON.stringify(params))

  this.on 'change', 'input[type="checkbox"]', ->
    $(this).parents('form:first').submit()