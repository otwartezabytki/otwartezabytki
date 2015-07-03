#= require ../../variables

angular.module('Relics').controller 'WalkingGuideCtrl',
  ($scope, $timeout, $modal, $cookies, Relic, WalkingGuide) ->
    $scope.query = ''
    $scope.widget =
      relics: []
      relic_ids: []
      title: ''
      description: ''
    $scope.suggestions = null
    $scope.currentPage = 1
    $scope.totalPages = -1
    $scope.loading = false
    $scope.saved = false
    $scope.error = false
    directionsService  = new google.maps.DirectionsService()
    directionsRenderers = []
    directionsData = []
    latLngBounds = {}
    findRoutePromises = []
    relicsChunks = []
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
      $cookies.walkingGuideQuery = $scope.query
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
        $scope.error = true

      $scope.loading = true
      Relic.suggestions({ query, place, page: $scope.currentPage }).then(success, error)

    $scope.nextPage = ->
      $scope.currentPage = Math.min($scope.totalPages, $scope.currentPage + 1)
      $scope.loadRelics()

    $scope.getIcon = (first, last) ->
      if first
        gmap_marker_green
      else if last
        gmap_marker_red
      else
        gmap_marker

    $scope.loadRelicInfo = (relic) ->
      $scope.loading = true
      Relic.get(relic.id).then (result) ->
        angular.extend(relic, result.data)
        relic.showInfoWindow = true
        $scope.loading = false

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
      clearErrors()
      $scope.suggestions = null
      $scope.currentPage = 1
      $scope.totalPages = -1

    $scope.clearRoute = ->
      clearErrors()
      for promise in findRoutePromises
        $timeout.cancel(promise)

      for renderer in directionsRenderers
        renderer.setMap(null)

      findRoutePromises   = []
      directionsRenderers = []
      directionsData      = []

    clearErrors = ->
      $scope.error = false

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
          $scope.error = true

    getDelay = ->
      diff = Date.now() - lastQueryTimestamp
      if diff >= 1000
        50
      else
        Math.max(50, 1000 - diff)

    $scope.drawRoute = ->
      # Split relics in to chunks to prevent MAX_WAYPOINTS_EXCEEDED error
      relicsChunks = relicsIntoChunks()
      $scope.clearRoute()

      if $scope.widget.relics.length < 2
        return $scope.resetMap()

      $scope.loading = true

      promise = $timeout ->
        findRoute()
      , getDelay()
      findRoutePromises.push(promise)

    $scope.sortableOptions =
      update: (e, ui) ->
        $scope.drawRoute()
      axis: 'y'

    $scope.load = (id) ->
      success = (response) ->
        $scope.loading = false
        $scope.saved = true
        $scope.widget = angular.copy(response.data)
        if $scope.map.instance
          $scope.drawRoute()
        else
          $scope.$watch 'map.instance', (newVal, oldVal) ->
            return if newVal == oldVal
            $scope.drawRoute()

      error = (response) ->
        $scope.loading = false
        $scope.error = true

      $scope.loading = true
      WalkingGuide.get(id).then(success, error)

    $scope.manualSave = ->
      $scope.save(true)

    $scope.save = (manual = false) ->
      $scope.widget.relic_ids = $scope.widget.relics.map (r) -> r.id
      $scope.widget.manual = manual
      $scope.saving = true

      success = (response) ->
        $scope.saving = false
        $scope.saved = true
        angular.extend($scope.widget, _.pick(response.data, ['uid', 'width', 'height', 'widget_url', 'print_path']))

      error = (response) ->
        $scope.saving = false
        $scope.error = true

      if $scope.widget.uid
        WalkingGuide.update($scope.widget).then(success, error)
      else
        WalkingGuide.create($scope.widget).then(success, error)

    $scope.$watch 'query', (newVal, oldVal) ->
      return if newVal == oldVal
      if newVal == ''
        $scope.resetForm()

    autosave = _.throttle (newVal, oldVal) ->
      return if _.isEqual(newVal, oldVal)
      $scope.save()
    , 1000

    $scope.$watch 'widget', autosave, true

    $scope.$watch 'widget.relics', (newVal, oldVal) ->
      return if newVal.length == oldVal.length
      google.maps.event.trigger($scope.map.instance, 'resize')
    , true

    $scope.openDescriptionModal = (relic) ->
      modalInstance = $modal.open
        templateUrl: 'walking-guide/description-modal.html'
        controller: 'WalkingGuideModalCtrl'
        resolve:
          relic: -> relic

    $timeout ->
      if $cookies.walkingGuideQuery
        $scope.query = $cookies.walkingGuideQuery
        $scope.searchRelics()


angular.module('Relics').controller 'WalkingGuideModalCtrl', ($scope, $modalInstance, relic) ->

  $scope.relic = relic

  $scope.close = ->
    $modalInstance.dismiss('cancel')
