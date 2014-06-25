angular.module('Relics', [
  'prevent-default', 'ozService',
  'ngSanitize', 'google-maps', 'ngDragDrop', 'ui.sortable'
])

angular.module('Relics').config ($httpProvider) ->
  $httpProvider.defaults.headers.common['X-CSRF-Token'] =
    angular.element(
      document.querySelector('meta[name=csrf-token]')
    ).attr('content')
