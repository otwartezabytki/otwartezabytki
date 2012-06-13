# Entering admin panel for first time

Then /^I should be redirected to Sign In page$/ do
  current_url.should include new_user_session_path
end

Then /^I see link to Sign Up page$/ do
  page.should have_css 'a', :href => new_user_registration_path
end

# Registering as new user

Given /^there are no users in database$/ do
  User.count.should eq 0
end

Given /^I've just visited to Sign Up page$/ do
  visit new_user_registration_path
end

When /^I navigate to \/admin$/ do
  visit admin_dashboard_path
end

When /^I fill email field with "(.*?)"$/ do |email|
  fill_in 'user_email', :with => email
end

When /^I fill password field with "(.*?)"$/ do |password|
  fill_in 'user_password', :with => password
end

When /^I submit the form$/ do
  find(:css, '[name="commit"]').click
end

Then /^there is one non\-admin user in database$/ do
  User.count.should eq 1
  User.first.role.should_not eq 'admin'
end

Then /^I have no access to application dashboard$/ do
  expect{ visit admin_dashboard_path }.to raise_error(CanCan::AccessDenied)
end
