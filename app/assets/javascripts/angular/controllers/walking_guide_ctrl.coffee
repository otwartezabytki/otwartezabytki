#= require ../../variables

angular.module('Relics').controller 'WalkingGuideCtrl',
  ($scope, $timeout, Relic, WalkingGuide) ->
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
    directionsRenderers = []
    directionsData = []
    latLngBounds = {}
    findRoutePromises = []
    relicsChunks = []
    markers = []
    center =
      latitude: 52.4118436
      longitude: 19.0984013
    zoom = 6
    lastQueryTimestamp = 0

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

    createMarker = (relic) ->
      new google.maps.Marker
        map: $scope.map.instance
        position: relicLatLng(relic)
        icon: gmap_marker # From variables.js

    clearMarkers = ->
      for marker in markers
        marker.setMap(null)
      markers = []

    drawMarkers = ->
      for relic in $scope.widget.relics
        markers.push(createMarker(relic))

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
      for promise in findRoutePromises
        $timeout.cancel(promise)

      for renderer in directionsRenderers
        renderer.setMap(null)

      clearMarkers()

      findRoutePromises   = []
      directionsRenderers = []
      directionsData      = []

    relicLatLng = (relic) ->
      new google.maps.LatLng(relic.latitude, relic.longitude)

    requestParams = (relics) ->
      origin: relicLatLng(relics.first())
      destination: relicLatLng(relics.last())
      waypoints: relics.slice(1, -1).map (relic) -> location: relicLatLng(relic)
      travelMode: google.maps.TravelMode.WALKING

    relicsIntoChunks = ->
      relics = $scope.widget.relics
      return [] if !relics.length
      chunks = []
      for i in [0...relics.length] by 9
        chunk = relics.slice(i, i + 10)
        chunks.push(chunk) if chunk.length > 1
      chunks

    renderDirections = (callback) ->
      latLngBounds = new google.maps.LatLngBounds()

      for data, index in directionsData
        directionsRenderer = new google.maps.DirectionsRenderer
          suppressMarkers: true
          preserveViewport: true
        directionsRenderer.setDirections(data)
        directionsRenderer.setMap($scope.map.instance)
        directionsRenderers.push(directionsRenderer)

        for route in data.routes
          latLngBounds.union(route.bounds)

        if directionsData.length == index + 1
          drawMarkers()
          $scope.map.instance.fitBounds(latLngBounds, true)
          callback()

    findRoute = (index = 0) ->
      relics  = relicsChunks[index]
      request = requestParams(relics)
      last    = index + 1 == relicsChunks.length

      directionsService.route request, (result, status) ->
        lastQueryTimestamp = Date.now()
        if status == google.maps.DirectionsStatus.OK
          directionsData.push(result)
          if last
            # Render directions if this is the last request
            renderDirections ->
              $scope.loading = false
          else
            # Delay every two requests to prevent OVER_QUERY_LIMIT
            delay = if index % 2
              1000
            else
              50
            promise = $timeout ->
              findRoute(index + 1)
            , delay
            findRoutePromises.push(promise)
        else
          console.error status # TODO: handle error

    getDelay = ->
      diff = Date.now() - lastQueryTimestamp
      delay = if diff >= 1000
        50
      else
        Math.min(50, 1000 - diff)

    $scope.drawRoute = ->
      # Split relics in to chunks to prevent MAX_WAYPOINTS_EXCEEDED error
      relicsChunks = relicsIntoChunks()
      $scope.loading = true
      $scope.clearRoute()

      if $scope.widget.relics.length < 2
        return $scope.resetMap()

      promise = $timeout ->
        findRoute()
      , getDelay()
      findRoutePromises.push(promise)

    $scope.sortableOptions =
      update: (e, ui) ->
        $scope.drawRoute()
      axis: 'y'

    $scope.edit = (id) ->
      success = (response) ->
        $scope.loading = false
        $scope.widget = angular.copy(response.data)
        if $scope.map.instance
          $scope.drawRoute()
        else
          $scope.$watch 'map.instance', (newVal, oldVal) ->
            return if newVal == oldVal
            $scope.drawRoute()

      error = (response) ->
        $scope.loading = false
        # TODO: handle error

      $scope.loading = true
      WalkingGuide.get(id).then(success, error)

    $scope.save = ->
      $scope.widget.relic_ids = $scope.widget.relics.map (r) -> r.id
      $scope.saving = true

      success = (response) ->
        $scope.saving = false
        angular.extend($scope.widget, response.data)

      error = (response) ->
        $scope.saving = false
        # TODO: handle error

      if $scope.widget.uid
        WalkingGuide.update($scope.widget).then(success, error)
      else
        WalkingGuide.create($scope.widget).then(success, error)

    $scope.$watch 'query', (newVal, oldVal) ->
      return if newVal == oldVal
      if newVal == ''
        $scope.resetForm()
