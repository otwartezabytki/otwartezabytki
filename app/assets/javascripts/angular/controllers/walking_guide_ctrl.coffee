angular.module('Relics').controller 'WalkingGuideCtrl',
  ($scope, Relic) ->
    $scope.query = ''
    $scope.relics = []
    directionsService  = new google.maps.DirectionsService()
    directionsRenderer = new google.maps.DirectionsRenderer()
    center =
      latitude: 52.4118436
      longitude: 19.0984013
    zoom = 6

    $scope.map =
      instance: null
      center: center
      zoom: zoom
      events:
        tilesloaded: (map) ->
          $scope.$apply ->
            $scope.map.instance = map

    $scope.searchRelic = ->
      items = $scope.query.split(',')
      query = items[0]
      place = if items.length > 1
        items.slice(1).join(',').trim()
      else
        ''
      Relic.suggestions({ query, place }).then (response) ->
        $scope.suggestions = response.data

    $scope.selectRelic = (relic) ->
      _relic = angular.copy(relic)
      _relic.latlng = new google.maps.LatLng(relic.latitude, relic.longitude)
      $scope.relics.push(_relic)
      $scope.drawRoute()
      $scope.removeSuggestion(relic)

    $scope.removeSuggestion = (relic) ->
      index = $scope.suggestions.relics.indexOf(relic)
      $scope.suggestions.relics.splice(index, 1)

    $scope.removeRelic = (relic) ->
      index = $scope.relics.indexOf(relic)
      $scope.relics.splice(index, 1)
      $scope.drawRoute()

    $scope.resetMap = ->
      $scope.map.instance.setCenter(new google.maps.LatLng(center.latitude, center.longitude))
      $scope.map.instance.setZoom(zoom)

    $scope.clearRoute = ->
      directionsRenderer.setMap(null)

    $scope.drawRoute = ->
      $scope.clearRoute()

      if !$scope.relics.length
        return $scope.resetMap()

      request =
        origin: $scope.relics.first().latlng
        destination: $scope.relics.last().latlng
        waypoints: $scope.relics.slice(1, -1).map (relic) -> location: relic.latlng
        travelMode: google.maps.TravelMode.WALKING

      directionsService.route request, (result, status) ->
        if status == google.maps.DirectionsStatus.OK
          directionsRenderer.setDirections(result)
          directionsRenderer.setMap($scope.map.instance)
        else
          # TODO
