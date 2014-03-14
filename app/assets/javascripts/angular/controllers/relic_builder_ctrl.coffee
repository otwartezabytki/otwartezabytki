angular.module('Relics').controller "RelicBuilderCtrl", ($scope, Suggester, $log) ->
  $scope.relic = {}
  $scope.location = {}
  $scope.places = []
  $scope.marker_holder = true

  $scope.map =
    instance: null
    center:
      latitude: 52.4118436,
      longitude: 19.0984013,
    zoom: 6
    events:
      tilesloaded: (map) ->
        $scope.$apply ->
          $log.info('this is the map instance', map)
          $scope.map.instance = map
      dragend: (event) ->
        console.log 'dragend', event

  $scope.searchPlace = (e) ->
    # WIP
    console.log 'searchPlace', $scope.location
    Suggester.placeFromPoland(q: $scope.location.place_name).then (response) ->
      $scope.places = response.data

  $scope.selectPlace = (place) ->
    # WIP
    console.log 'place selected:', place

  $scope.onMarkerHolderDrop = (event, ui) ->
    $scope.marker_holder = false

    $div = $($scope.map.instance.getDiv())
    x_offset    = (ui.offset.left - $div.offset().left + 39)
    y_offset    = (ui.offset.top - $div.offset().top + 55)

    bounds = $scope.map.instance.getBounds()
    lat    = bounds.getNorthEast().lat()
    lng    = bounds.getSouthWest().lng()
    width  = bounds.getNorthEast().lng() - bounds.getSouthWest().lng()
    height = bounds.getSouthWest().lat() - bounds.getNorthEast().lat()

    latlng = new google.maps.LatLng(
      lat + height * y_offset / $div.height(),
      lng + width * x_offset / $div.width()
    )
    setMarker(latlng)

  setMarker = (latlng) ->
    # $('form.relic').addClass('geocoded')
    # $('#relic_geocoded').val("t")
    # $scope.map.instance.removeMarkers()
    $scope.map.circle.setMap(null)

    marker = new google.maps.Marker(
      position: latlng
      map: $scope.map.instance
      draggable: true
    )

    google.maps.event.addListener(marker, "dragend", (event) ->
      # new_lat = marker.getPosition().lat().round(7)
      # new_lng = marker.getPosition().lng().round(7)
      # $('#relic_latitude').val(new_lat)
      # $('#relic_longitude').val(new_lng)
      zoomAt(event.latLng)
    )
    zoomAt(latlng)

  zoomAt = (latlng, zoom = 17) ->
    $scope.map.instance.setCenter(latlng)
    $scope.map.instance.setZoom(zoom)

  circleMarker = (latlng) ->
    icon = new google.maps.MarkerImage(
      small_marker_image_path, null, null, new google.maps.Point(8, 8)
    )
    $scope.map.circle = new google.maps.Marker(
      position: latlng
      icon: icon
      map: $scope.map.instance
    )

  $scope.$watch 'map.instance', (newVal, oldVal) ->
    if newVal
      $log.info 'map changed'
      try
        navigator.geolocation.getCurrentPosition (pos) ->
          latlng = new google.maps.LatLng(pos.coords.latitude, pos.coords.longitude)
          zoomAt(latlng)
          circleMarker(latlng)

  $scope.$watch 'relic.relic_group', (newVal, oldVal) ->
    if newVal != oldVal
      # .r_ze and .r_sa is hardcoded in translation strings
      if newVal
        $('.new_relic .r_ze').css(display: 'inline')
        $('.new_relic .r_sa').css(display: 'none')
      else
        $('.new_relic .r_ze').css(display: 'none')
        $('.new_relic .r_sa').css(display: 'inline')
