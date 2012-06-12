Given /^I'm not logged in as admin user$/ do
  @current_user = nil
end

Given /^I'm logged in as administrator$/ do
  @current_user = FactoryGirl.create :user, :admin
  visit new_user_session_path
  fill_in 'user_email', :with => @current_user.email
  fill_in 'user_password', :with => 'password'
  find('[name="commit"]').click
  visit admin_dashboard_path
  page.should have_selector('body.logged_in')
end