jQuery.initializer 'section.edit.categories', ->
  $('#relic_tags').select2
    query: (query) -> $.get('/tags?query=q', (tags) -> query.callback({ results: tags }))
    initSelection: (element, callback) ->
      data = []
      $(element.val().split(',')).each(-> data.push({ id: this, text: this }))
      callback(data)
    multiple: true