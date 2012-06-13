@dev
Feature:
  In order give admin access to other users
  As current administrator of application
  I want to confirm newly-registered user as administrator

Background:
  Given "bob@example.com" is an e-mail of registered user
    And he is not yet confirmed as administrator
    And I'm logged in as administrator

Scenario: Successful confirmation of user
  When I navigate to edit page of "bob@example.com" user
   And I fill user role with "admin"
   And I submit the form
  Then the user is confirmed as administrator