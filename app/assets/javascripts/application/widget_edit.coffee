jQuery.initializer '.edit_widget', ->
  console.log('initializer')
  oz = new OZ('oz_map_search')
  oz.api 'on_params_changed', (params) ->
    $('#widget_map_search_api_params').val(JSON.stringify(params))