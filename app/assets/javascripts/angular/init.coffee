angular.module('Relic', ['prevent-default'])

angular.module('Relic').config ($httpProvider) ->
  $httpProvider.defaults.headers.common['X-CSRF-Token'] =
    angular.element(
      document.querySelector('meta[name=csrf-token]')
    ).attr('content')
