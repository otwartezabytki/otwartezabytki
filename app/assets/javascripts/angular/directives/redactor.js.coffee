angular.module('Relics').directive "redactor", ($timeout) ->
  restrict: "A"
  require: "ngModel"

  link: (scope, element, attrs, ngModel) ->
    options =
      keyupCallback: (redactor) ->
        scope.$apply ->
          ngModel.$setViewValue(redactor.getCode())

    additionalOptions = (if attrs.redactor then scope.$eval(attrs.redactor) else {})
    angular.extend(options, additionalOptions)

    # put in timeout to avoid $digest collision.
    $timeout ->
      editor = element.redactor(options)
      editor.setCode(ngModel.$viewValue || "")
