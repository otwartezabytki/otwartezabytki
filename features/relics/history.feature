Feature: Revision history
  As an admin user
  I want to see the relics revision history

Background:
  Given I'm logged in as administrator
    And there is at least one relic in database
    And identification of that relic have been modified

Scenario: Seeing link to history of relic
   When I navigate to history of the relic
   Then I should see that someone have modified it's identification

Scenario: Reverting previous version of the Relic
  Given I'm previewing previous version of the Relic
   When I click on the "Przywróć tę wersję" link
   Then the identification of the Relic should be reverted
    And Relic shuld have one more version registered
    And I should see reverted version of the Relic