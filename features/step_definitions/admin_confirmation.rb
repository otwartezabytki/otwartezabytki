Given /^"(.*?)" is an e-mail of registered user$/ do |email|
  @user = FactoryGirl.create :user, :email => email
end

Given /^he is not yet confirmed as administrator$/ do
  @user.role.should_not eq 'admin'
end

When /^I navigate to edit page of "(.*?)" user$/ do |email|
  find('#users a').click
  within('#q_search') do
    fill_in 'q_email', :with => email
    find('[name="commit"]').click
  end

  find('table').should have_content(email)
  find('table a.edit_link').click
  page.should have_selector('#user_email', :value => email)
end

When /^I fill user role with "([^"]*)"$/ do |role|
  find("#user_role_input option[value='#{role}']").select_option
end

Then /^the user is confirmed as administrator$/ do
  @user.reload.should be_admin
end

Then /^I land on the same page as before clicking$/ do
  current_url.should eq @before_clicking_url
end