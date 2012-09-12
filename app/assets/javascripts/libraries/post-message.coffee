# everything is wrapped in the XD function to reduce namespace collisions
XD = do ->
  interval_id = undefined
  last_hash = undefined
  cache_bust = 1
  attached_callback = undefined
  window = this
  postMessage: (message, target_url, target) ->
    return  unless target_url
    target = target or parent # default to parent
    if window["postMessage"]

      # the browser supports window.postMessage, so call it with a targetOrigin
      # set appropriately, based on the target_url parameter.
      target["postMessage"] message, target_url.replace(/([^:]+:\/\/[^\/]+).*/, "$1")

      # the browser does not support window.postMessage, so use the window.location.hash fragment hack
    else target.location = target_url.replace(/#.*$/, "") + "#" + (+new Date) + (cache_bust++) + "&" + message  if target_url

  receiveMessage: (callback, source_origin) ->

    # browser supports window.postMessage
    if window["postMessage"]

      # bind the callback to the actual event associated with window.postMessage
      if callback
        attached_callback = (e) ->
          return not 1  if (typeof source_origin is "string" and e.origin isnt source_origin) or (Object::toString.call(source_origin) is "[object Function]" and source_origin(e.origin) is not 1)
          callback e
      if window["addEventListener"]
        window[(if callback then "addEventListener" else "removeEventListener")] "message", attached_callback, not 1
      else
        window[(if callback then "attachEvent" else "detachEvent")] "onmessage", attached_callback
    else

      # a polling loop is started & callback is called whenever the location.hash changes
      interval_id and clearInterval(interval_id)
      interval_id = null
      if callback
        interval_id = setInterval(->
          hash = document.location.hash
          re = /^#?\d+&/
          if hash isnt last_hash and re.test(hash)
            last_hash = hash
            callback data: hash.replace(re, "")
        , 100)

class window.OZ

  getDomainFromUrl = (url) ->
    url = window.location.protocol + url  if url.substr(0, 2) is "//"
    url_pieces = url.split("/")
    domain_str = ""
    i = 0
    length = url_pieces.length

    while i < length
      if i < 3
        domain_str += url_pieces[i]
      else
        break
      domain_str += "/"  if i < 2
      i++
    domain_str

  isFunction = (obj) -> !!(obj and obj.constructor and obj.call and obj.apply)

  messageReceived = (e) ->
    try
      data = JSON.parse(e.data)
      event = data.event
      params = data.params

    @callbacks[event].call(null, params) if @callbacks[event]

  constructor: (id, callback) ->
    @callbacks = { ready: callback }
    @iframe = document.getElementById(id)
    XD.receiveMessage(messageReceived.bind(this))

  api: (event, valueOrCallback) ->
    params = unless isFunction(valueOrCallback) then valueOrCallback else null
    callback = if isFunction(valueOrCallback) then valueOrCallback else null

    if callback
      @callbacks[event] = callback

    XD.postMessage({ event: event, params: params }, @iframe.src, @iframe.contentWindow)