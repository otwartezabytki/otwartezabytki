#= require vendor/debounce.jquery

window.gmaps =
  load: (api_key, callback) ->
    if google?.maps?
      do callback
    else
      $(window).on('gmaps.loaded', callback)
      script = document.createElement("script")
      script.type = "text/javascript"
      script.src = "http://maps.googleapis.com/maps/api/js?key=#{api_key}&sensor=false&callback=gmaps.loaded"
      document.body.appendChild(script)

  loaded: ->
    do gmaps.extend
    $(window).trigger('gmaps.loaded')

  extend: ->
    do add_marker_helpers = ->
      google.maps.Map::markers = []
      google.maps.Map::overlays = []
      google.maps.Map::getMarkers = -> @markers
      google.maps.Map::getOverlays = -> @overlays

      google.maps.Map::clearMarkers = ->
        marker.setMap null for marker in @markers
        @markers = []

      google.maps.Map::clearOverlays = ->
        overlay.setMap null for overlay in @overlays
        @overlays = []

      google.maps.Marker::_setMap = google.maps.Marker::setMap
      google.maps.Marker::setMap = (map) ->
        map.markers[map.markers.length] = this  if map
        @_setMap map

      google.maps.OverlayView::_setMap = google.maps.OverlayView::setMap
      google.maps.OverlayView::setMap = (map) ->
        map.overlays[map.overlays.length] = this if map
        @_setMap map

      google.maps.LatLngBounds::toString = ->
        this.toUrlValue().split(',').inGroupsOf(2).map((e) -> e.join(',')).join(';')

    do construct_relic_marker = ->
      class google.maps.RelicMarker extends google.maps.OverlayView
        constructor: (@latlng, @number = 1, @click) ->

        draw: ->
          image_url = gmap_circles[@number.toString().length - 1]
          image_size = [55, 59, 75, 85, 105][@number.toString().length - 1]
          font_size = [14, 14, 17, 17, 17][@number.toString().length - 1]

          # cache drawn image
          @div ||= do =>
            marker = $("<div>#{@number}</div>").css
              position: "absolute"
              cursor: "pointer"
              textAlign: 'center'
              height: image_size
              width: image_size
              lineHeight: "#{image_size}px"
              fontWeight: "800"
              fontSize: font_size
              color: "#507283"
              backgroundImage: "url(#{image_url})"
              zIndex: 10000

            $(@getPanes().overlayImage).append(marker)

            google.maps.event.addDomListener marker[0], 'click', (e) =>
              @click() if @click?
              false

            marker

          if point = @getProjection().fromLatLngToDivPixel(@latlng)
            @div.css(left: point.x - image_size/2, top: point.y - image_size/2)

        remove: ->
          @div.remove() if @div

    do on_next_movement_feature = ->
      google.maps.GoogleMap = google.maps.Map

      class google.maps.Map extends google.maps.GoogleMap

        @THROTTLE_TIME = 3000
        @PREVENT_FIRST_IDLE = true

        directions: new google.maps.DirectionsService
        
        getLatLngBounds: ->
          if bounds = @getBounds()
            north_east = bounds.getNorthEast()
            south_west = bounds.getSouthWest()
            bounds = new google.maps.LatLngBounds(
              new google.maps.LatLng(north_east.lat(), south_west.lng())
              new google.maps.LatLng(south_west.lat(), north_east.lng())
            )

        onMovement: (callback) -> @onMovementCallback = callback
        onNextMovement: (callback) -> @onNextMovementCallback = callback

        constructor: ->
          super

          google.maps.event.addListener this, 'idle',
            jQuery.throttle ->
              if @onNextMovementCallback?
                idle_event = @onNextMovementCallback
                @onNextMovementCallback = undefined
                do idle_event
              else
                do @onMovementCallback if @onMovementCallback
            , @THROTTLE_TIME

          if @PREVENT_FIRST_IDLE
            this.onNextMovement ->

          @directionsRenderer = new google.maps.DirectionsRenderer
            map: this

        setZoom: (zoom) ->
          zoom += 1 if @fittingBounds
          super
          @fittingBounds = false

        fitBounds: (bounds) ->
          @fittingBounds = true
          super
