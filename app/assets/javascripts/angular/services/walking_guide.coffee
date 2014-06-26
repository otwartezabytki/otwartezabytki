angular.module('Relics').factory 'WalkingGuide', ($http) ->
  base = '/widgets/walking_guide'

  getParams = (params) ->
    relic_ids: params.relic_ids
    description: params.description

  get: (id) ->
    $http.get("#{base}/#{id}.json")

  create: (params) ->
    $http.post("#{base}.json", widget_walking_guide: params: getParams(params))

  update: (params) ->
    $http.put("#{base}/#{params.uid}.json", widget_walking_guide: params: getParams(params))

  destroy: (id) ->
    $http.delete("#{base}/#{id}.json")
