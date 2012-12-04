jQuery.initializer 'section.new.alert', ->
  $("section.new.alert form.alert").submit ->
    $("section.new.alert .row").append('<div class="opacity"></div>').append '<div class="loading"><div class="inner"><div class="loader"><img src="/assets/fancybox/fancybox_loading.gif" alt="loading..." /></div></div></div>'
    submit = $(this).find(":submit").attr("value", "Wysyłam").css("padding", "0 22px 0 23px")