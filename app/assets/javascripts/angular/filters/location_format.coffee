angular.module('Relics').filter 'locationFormat', ($sce) ->
  (input) ->
    if input
      result = input.slice(0, -1)
      result.push("<strong>#{input.slice(-1)}</strong>")
      $sce.trustAsHtml(result.join(' > '))
