angular.module('ozService', [])
  .factory 'Suggester', ($http) ->
    placeFromPoland: (params) ->
      $http.get("/suggester/place_from_poland.json", { isArray: true, params: params })
  .factory 'AdministrativeDivision', ($http) ->
    get: (params) ->
      $http.get("/administrative_divisions.json", { isArray: true, params: params })
