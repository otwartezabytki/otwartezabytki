# encoding: utf-8
require "spec_helper"

module RequestHelpers

  def logout_user(user = @current_user)
    Capybara.reset_sessions!
    visit destroy_user_session_url
  end

  def login_as(user)
    logout_user if @current_user
    @current_user = user
    visit new_user_session_path
    fill_in 'Adres e-mail', :with => user.email
    fill_in 'Hasło', :with => user.password
    click_on 'Zaloguj się'
    page.should_not have_content('Zaloguj')
  end

end