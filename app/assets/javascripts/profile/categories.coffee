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

  $("form.relic").submit ->
    $("section.edit").append('<div class="opacity"></div>').append '<div class="loading"><div class="inner"><div class="loader"><img src="/assets/fancybox/fancybox_loading.gif" alt="loading..." /></div></div></div>'
    submit = $(this).find(":submit").attr("value", "Zapisuję").css("padding", "0 31px")