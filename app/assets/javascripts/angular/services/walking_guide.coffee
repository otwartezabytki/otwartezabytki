angular.module('Relics').factory 'WalkingGuide', ($http) ->
  base = '/widgets/walking_guide'

  getData: (params) ->
    params:
      relic_ids: params.relic_ids
      title: params.title
      description: params.description
      private: params.private
    width: params.width
    height: params.height

  get: (id) ->
    $http.get("#{base}/#{id}.json")

  create: (params) ->
    $http.post("#{base}.json", { widget_walking_guide: @getData(params), manual: params.manual })

  update: (params) ->
    $http.put("#{base}/#{params.uid}.json", { widget_walking_guide: @getData(params), manual: params.manual })

  destroy: (id) ->
    $http.delete("#{base}/#{id}.json")
