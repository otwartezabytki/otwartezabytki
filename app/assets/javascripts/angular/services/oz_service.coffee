angular.module('ozService', [])
  .factory 'Suggester', ($http) ->
    placeFromPoland: (params) ->
      $http.get("/suggester/place_from_poland.json", { isArray: true, params: params })
