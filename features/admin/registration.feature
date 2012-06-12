Feature: Admin user registration
  In order to freely manage relics
  As non-registered administrator of application
  I want to create account with access to dashboard

Scenario: Entering admin panel for first time
  Given I'm not logged in as admin user
  When I navigate to /admin
  Then I should be redirected to Sign In page
   And I see link to Sign Up page

Scenario: Registering as new user
  Given there are no users in database
    And I've just visited to Sign Up page
  When I fill email field with "admin@example.com"
   And I fill password field with "password"
   And I submit the form
  Then there is one non-admin user in database
   And I have no access to application dashboard

