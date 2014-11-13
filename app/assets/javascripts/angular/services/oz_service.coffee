angular.module('ozService', [])
  .factory 'Suggester', ($http) ->
    placeFromPoland: (params) ->
      $http.get("/suggester/place_from_poland.json", { isArray: true, params: params })
  .factory 'AdministrativeDivision', ($http) ->
    get: (params) ->
      $http.get("/administrative_divisions.json", { isArray: true, params: params })
  .factory 'Relic', ($http) ->
    suggestions: (params) ->
      $http.get("/api/v1/relics/suggestions.json", { isArray: true, params: params })
    get: (id) ->
      $http.get("/api/v1/relics/#{id}.json")
