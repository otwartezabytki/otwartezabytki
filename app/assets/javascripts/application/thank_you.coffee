jQuery.initializer 'body.thank_you', ->
  window.fbAsyncInit = ->
    FB.init
      appId: "179800448818038"
      status: true
      cookie: true
      xfbml: true

    document.getElementById("share").onclick = ->
      obj =
        method: "feed"
        redirect_uri: "http://#{document.location.hostname}/facebook/share_close"
        link: "http://#{document.location.hostname}"
        name: "Otwarte Zabytki"
        caption: "społecznościowa akcja tworzenia bazy zabytków. Dołącz!"
        picture: "http://#{document.location.hostname}#{logo_facebook}"
        display: "popup"

      FB.ui obj

  js = undefined
  id = "facebook-jssdk"
  ref = document.getElementsByTagName("script")[0]
  return if document.getElementById(id)
  js = document.createElement("script")
  js.id = id
  js.async = true
  js.src = "//connect.facebook.net/pl_PL/all.js"
  ref.parentNode.insertBefore js, ref
