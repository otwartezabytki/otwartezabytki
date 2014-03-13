angular.module('Relics').controller "RelicBuilderCtrl", ($scope, Suggester) ->
  $scope.relic = {}
  $scope.location = {}
  $scope.places = []

  $scope.searchPlace = (e) ->
    # WIP
    console.log 'searchPlace', $scope.location
    Suggester.placeFromPoland(q: $scope.location.place_name).then (response) ->
      $scope.places = response.data

  $scope.selectPlace = (place) ->
    # WIP
    console.log 'place selected:', place

  $scope.$watch 'relic.relic_group', (newVal, oldVal) ->
    if newVal != oldVal
      # .r_ze and .r_sa is hardcoded in translation strings
      if newVal
        $('.new_relic .r_ze').css(display: 'inline')
        $('.new_relic .r_sa').css(display: 'none')
      else
        $('.new_relic .r_ze').css(display: 'none')
        $('.new_relic .r_sa').css(display: 'inline')
