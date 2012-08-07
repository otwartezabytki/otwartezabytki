# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "Authorization" do

  describe "GET /login" do
    it "it should authorize user after filling the form" do
      visit('/')
      page.should have_link('Zaloguj')
      click_link('Zaloguj')

      user = create(:registered_user, :password => "password", :password_confirmation => "password")
      visit new_user_session_path

      within('form#new_user') do
        fill_in 'Adres e-mail', :with => user.email
        fill_in 'Hasło', :with => user.password
      end

      refresh_relics_index
      click_on "Zaloguj się"

      page.should_not have_link('Zaloguj')
      page.should have_content(user.username)
    end
  end

end