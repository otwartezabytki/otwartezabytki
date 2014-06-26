angular.module('Relics').controller 'WalkingGuideCtrl',
  ($scope, Relic, WalkingGuide) ->
    $scope.query = ''
    $scope.widget =
      relics: []
      relic_ids: []
      description: ''
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
      $scope.widget.relics.push(angular.copy(relic))
      $scope.drawRoute()

    $scope.filteredSuggestions = ->
      if $scope.widget.relics.length && $scope.suggestions
        $scope.suggestions.exclude (suggestion) ->
          $scope.widget.relics.some (relic) ->
            suggestion.id == relic.id
      else
        $scope.suggestions

    $scope.removeRelic = (relic) ->
      index = $scope.widget.relics.indexOf(relic)
      $scope.widget.relics.splice(index, 1)
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

    relicLatLng = (relic) ->
      new google.maps.LatLng(relic.latitude, relic.longitude)

    $scope.drawRoute = ->
      $scope.clearRoute()

      if !$scope.widget.relics.length
        return $scope.resetMap()

      request =
        origin: relicLatLng($scope.widget.relics.first())
        destination: relicLatLng($scope.widget.relics.last())
        waypoints: $scope.widget.relics.slice(1, -1).map (relic) -> location: relicLatLng(relic)
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

    $scope.edit = (id) ->
      success = (response) ->
        $scope.loading = false
        $scope.widget = angular.copy(response.data)

      error = (response) ->
        $scope.loading = false
        # TODO: handle error

      $scope.loading = true
      WalkingGuide.get(id).then(success, error)

    $scope.save = ->
      $scope.widget.relic_ids = $scope.widget.relics.map (r) -> r.id
      $scope.loading = true

      success = (response) ->
        $scope.loading = false
        angular.extend($scope.widget, response.data)

      error = (response) ->
        $scope.loading = false
        # TODO: handle error

      if $scope.widget.uid
        WalkingGuide.update($scope.widget).then(success, error)
      else
        WalkingGuide.create($scope.widget).then(success, error)

    $scope.$watch 'query', (newVal, oldVal) ->
      return if newVal == oldVal
      if newVal == ''
        $scope.resetForm()
