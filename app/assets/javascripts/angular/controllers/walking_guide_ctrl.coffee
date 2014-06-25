angular.module('Relics').controller 'WalkingGuideCtrl',
  ($scope, Relic) ->
    $scope.query = ''
    $scope.relics = []
    $scope.suggestions = null
    $scope.currentPage = 0
    $scope.totalPages = -1
    $scope.loading = false
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

    $scope.searchRelics = ->
      $scope.searchForm.submitted = true
      return if $scope.searchForm.$invalid
      $scope.resetSuggestions()
      $scope.loadRelics()

    $scope.loadRelics = ->
      items = $scope.query.split(',')
      query = items[0]
      place = if items.length > 1
        items.slice(1).join(',').trim()
      else
        ''

      success = (response) ->
        $scope.suggestions ||= []
        $scope.suggestions = $scope.suggestions.concat(response.data.relics)
        $scope.currentPage = response.data.meta.current_page
        $scope.totalPages  = response.data.meta.total_pages
        $scope.loading = false

      error = (response) ->
        $scope.loading = false
        # TODO

      $scope.loading = true
      Relic.suggestions({ query, place, page: $scope.currentPage }).then(success, error)

    $scope.nextPage = ->
      $scope.currentPage = Math.min($scope.totalPages - 1, $scope.currentPage + 1)
      $scope.loadRelics()

    $scope.selectRelic = (relic) ->
      _relic = angular.copy(relic)
      _relic.latlng = new google.maps.LatLng(relic.latitude, relic.longitude)
      $scope.relics.push(_relic)
      $scope.drawRoute()

    $scope.filteredSuggestions = ->
      if $scope.relics.length && $scope.suggestions
        $scope.suggestions.exclude (suggestion) ->
          $scope.relics.some (relic) ->
            suggestion.id == relic.id
      else
        $scope.suggestions

    $scope.removeRelic = (relic) ->
      index = $scope.relics.indexOf(relic)
      $scope.relics.splice(index, 1)
      $scope.drawRoute()

    $scope.resetMap = ->
      $scope.map.instance.setCenter(new google.maps.LatLng(center.latitude, center.longitude))
      $scope.map.instance.setZoom(zoom)

    $scope.resetForm = ->
      $scope.query = ''
      $scope.searchForm.submitted = false
      $scope.resetSuggestions()

    $scope.resetSuggestions = ->
      $scope.suggestions = null
      $scope.currentPage = 0
      $scope.totalPages = -1

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

    $scope.sortableOptions =
      update: (e, ui) ->
        $scope.drawRoute()
      axis: 'y'

    $scope.$watch 'query', (newVal, oldVal) ->
      return if newVal == oldVal
      if newVal == ''
        $scope.resetForm()
