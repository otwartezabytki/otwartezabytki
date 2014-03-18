angular.module('Relics').controller "RelicBuilderCtrl",
  ($scope, Suggester, AdministrativeDivision, $location, $anchorScroll) ->
    $scope.step = 1
    $scope.relic = {}
    $scope.location = {
      place_name: null
      lat: null
      lng: null
    }
    $scope.places = []
    $scope.marker_holder = true

    $scope.map =
      instance: null
      markers: []
      center:
        latitude: 52.4118436,
        longitude: 19.0984013,
      zoom: 6
      events:
        tilesloaded: (map) ->
          $scope.$apply ->
            $scope.map.instance = map

    $scope.administrative = {
      selected: {}
      options: {}
    }

    $scope.getAdministrative = (arg = null) ->
      params = {}
      if arg
        params["#{arg}_id"] = $scope.administrative.selected[arg].id
      AdministrativeDivision.get(params).then (response) ->
        options  = response.data.options
        selected = response.data.selected
        $scope.administrative.options = options
        _.each ['voivodeship', 'district', 'commune', 'place'], (name) ->
          $scope.administrative.selected[name] =
            _.find(options["#{name}s"], (v) -> v.id == selected[name]?.id)

    $scope.getAdministrative()

    $scope.searchPlace = (e) ->
      # WIP
      console.log 'searchPlace', $scope.location
      loaderShow()
      Suggester.placeFromPoland(q: $scope.location.place_name).then (response) ->
        $scope.places = response.data
        loaderHide()

    $scope.selectPlace = (place) ->
      setCircleMarker(new google.maps.LatLng(place.latitude, place.longitude))
      # scroll to map
      $location.hash('location-preview')
      $anchorScroll()
      # start setting location again
      $scope.marker_holder = true
      $scope.location.lat  = null
      $scope.location.lng  = null

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

    $scope.findNearestRelics = () ->
      if false
        # TODO make some magic display fancybox
      else
        $scope.goToStep(2)

    $scope.goToStep = (step) ->
      $scope.step = step

    $scope.knownAddress = ->
      !_.isEmpty($scope.location.street) || $scope.known_address

    $scope.toggleKnownAddress = ->
      $scope.location.street = null
      $scope.known_address   = !$scope.known_address

    removeMarkers = () ->
      _.each $scope.map.markers, (marker) ->
        marker.setMap(null)
      $scope.map.markers = []

    setMarker = (latlng) ->
      removeMarkers()
      marker = new google.maps.Marker(
        position: latlng
        map: $scope.map.instance
        draggable: true
      )
      $scope.map.markers.push(marker)

      google.maps.event.addListener(marker, "dragend", (event) ->
        $scope.location.lat = event.latLng.lat()
        $scope.location.lng = event.latLng.lng()
        zoomAt(event.latLng)
      )

      $scope.location.lat = latlng.lat()
      $scope.location.lng = latlng.lng()
      zoomAt(latlng)

    zoomAt = (latlng, zoom = 17) ->
      $scope.map.instance.setCenter(latlng)
      $scope.map.instance.setZoom(zoom)

    setCircleMarker = (latlng) ->
      removeMarkers()
      icon = new google.maps.MarkerImage(
        small_marker_image_path, null, null, new google.maps.Point(8, 8)
      )
      marker = new google.maps.Marker(
        position: latlng
        icon: icon
        map: $scope.map.instance
      )
      $scope.map.markers.push(marker)
      zoomAt(latlng)

    loaderShow = ->
      # TODO refactor
      $('#fancybox_loader_container').show()

    loaderHide = ->
      # TODO refactor
      $('#fancybox_loader_container').hide()

    $scope.$watch 'map.instance', (newVal, oldVal) ->
      if newVal && $scope.map.markers.length == 0
        try
          loaderShow()
          navigator.geolocation.getCurrentPosition (pos) ->
            latlng = new google.maps.LatLng(pos.coords.latitude, pos.coords.longitude)
            setCircleMarker(latlng)
            loaderHide()
        catch err
          loaderHide()

    $scope.$watch 'relic.relic_group', (newVal, oldVal) ->
      if newVal != oldVal
        # .r_ze and .r_sa is hardcoded in translation strings
        if newVal
          $('.new_relic .r_ze').css(display: 'inline')
          $('.new_relic .r_sa').css(display: 'none')
        else
          $('.new_relic .r_ze').css(display: 'none')
          $('.new_relic .r_sa').css(display: 'inline')
