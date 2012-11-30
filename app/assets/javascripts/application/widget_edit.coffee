jQuery.initializer '.edit_widget.map_search', ->
  oz = new OZ('oz_map_search')
  $form = $('form.widget_map_search')
  oz.api 'on_params_changed', (params) ->
    $('#widget_map_search_api_params').val(JSON.stringify(params))
    $.post $form.attr('action'), $form.serialize(), (data) ->
      $('textarea#snippet').val(data.snippet)
    , "json"

  this.on 'change', 'input[type="checkbox"], input[type="text"]', ->
    $form.submit()