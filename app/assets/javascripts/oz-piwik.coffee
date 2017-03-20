$ ->
  PiwikTracker = {
    EVENTS: {
        createdANewMonument: 'Created a new monument',
        addedANewPhoto: 'Added a new photo',
        editedField: 'Edited a Field'
        fields: {
          description: 'Description',
          location: 'Location',
          creationDate: 'Creation Date',
          interestingFact: 'Interesting Fact',
          tag: 'Tag',
          alert: 'Alert',
          importantDates: 'Important Dates',
          relicWidgets: 'Relic Widgets',
          officialDocuments: 'Official Documents'
        }
      }

    EDITED_FIELDS: {
      description: '.js-piwik-edited-description',
      location: '.js-piwik-edited-location',
      creationDate: '.js-piwik-edited-creation-date',
      interestingFact: '.js-piwik-edited-interesting-fact',
      tag: '.js-piwik-edited-tag',
      alert: '.js-piwik-edited-alert',
      importantDates: '.js-piwik-edited-important-dates',
      relicWidgets: '.js-piwik-edited-relic-widgets',
      officialDocuments: '.js-piwik-edited-official-documents'
    }

    PEOPLE: {
        user: 'User',
        admin: 'Admin'
      }

    getRole: () ->
      role = $('.js-piwik-user-or-admin')
      return null unless role.length
      @PEOPLE[role.attr('role')]

    getUserId: () ->
      role = $('.js-piwik-user-or-admin')
      return null unless role.length
      role.attr('userID')

    addedANewPhoto: ->
      if @getRole()
        _paq.push([
          'trackEvent',
          @getRole(),
          @getUserId(),
          @EVENTS['addedANewPhoto'],
        ])

    addedANewMonument: ->
      if @getRole()
        _paq.push([
          'trackEvent',
          @getRole(),
          @getUserId(),
          @EVENTS['createdANewMonument']
        ])

     editedField: (fieldType) ->
       if @getRole()
         _paq.push([
          'trackEvent',
          @getRole(),
          @getUserId(),
          @EVENTS['editedField'] + ' - ' +
          @EVENTS['fields'][fieldType]
         ])
  }

  window.PiwikTracker = PiwikTracker

  #  Edycja pola zabytku
  _.forEach( PiwikTracker.EDITED_FIELDS, (_class, _event) ->
    $(document).on('click', _class, () -> PiwikTracker.editedField(_event))
  )

  # Dodanie nowego zdjęcia
  $(document).on('click', '.js-piwik-added-a-new-photo', () -> PiwikTracker.addedANewPhoto())

  # Dodanie nowego zabytku
  $(document).on('click', '.js-piwik-added-a-new-monument', () -> PiwikTracker.addedANewMonument())