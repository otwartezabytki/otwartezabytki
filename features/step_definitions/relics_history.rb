# encoding: utf-8

Given /^there is at least one relic in database$/ do
  @relic = Relic.first
end

Given /^identification of that relic have been modified$/ do
  @old_identification = @relic.identification
  @relic.update_attributes(:identification => "New Identification")
  @version_count = @relic.versions.count
end


When /^I navigate to history of the relic$/ do
  visit history_admin_relic_path(@relic.id)
end

Then /^I should see that someone have modified it's identification$/ do
  page.should have_content("New Identification")
end

Given /^I'm previewing previous version of the Relic$/ do
  visit admin_relic_path(@relic.id, :version => @relic.versions.first.id)
end

When /^I click on the "(.*?)" link$/ do |name|
  click_link(name)
end

Then /^the identification of the Relic should be reverted$/ do
  @relic.reload.identification.should eq @old_identification
end

When /^Relic shuld have one more version registered$/ do
  @relic.reload.versions.count.should eq(@version_count + 1)
end

Then /^I should see reverted version of the Relic$/ do
  page.should have_content(@old_identification)
end
