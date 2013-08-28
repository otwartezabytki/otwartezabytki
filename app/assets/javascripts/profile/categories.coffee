jQuery.initializer 'section.edit.categories', ->
  $('#relic_tags').select2
    query: (query) -> $.get "/tags?query=#{query.term}", (tags) ->
      query.callback({ results: tags })
    , 'json'
    initSelection: (element, callback) ->
      data = []
      $(element.val().split(',')).each(-> data.push({ id: this, text: this }))
      callback(data)
    multiple: true
    createSearchChoice: (search) ->
      { id: search, text: search }

  autoCategories = $.parseJSON $('#auto_categories').html()
  markup         = $('#auto_categories_markup').html()
  autoCategories.each (category) ->
    $("input[value='#{category}']:checkbox").parent('label').append markup
  $('.auto_categories').tooltip()

jQuery.initializer 'section.show.categories', ->
  $('.auto_categories').tooltip()
