angular.module('Relics').factory 'WalkingGuide', ($http) ->
  base = '/widgets/walking_guide'

  getData: (params) ->
    widget_walking_guide:
      params:
        relic_ids: params.relic_ids
        description: params.description
      width: params.width
      height: params.height

  get: (id) ->
    $http.get("#{base}/#{id}.json")

  create: (params) ->
    $http.post("#{base}.json", @getData(params))

  update: (params) ->
    $http.put("#{base}/#{params.uid}.json", @getData(params))

  destroy: (id) ->
    $http.delete("#{base}/#{id}.json")
