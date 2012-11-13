# -*- encoding : utf-8 -*-
require "spec_helper"

describe "Relics profile" do

  describe "GET /relic" do
    it "should contain description of relic" do
      relic = create(:relic)

      visit relic_path(relic.id)
      page.should have_content(relic.description)
    end

    it "should display message and button for add description if it's not present" do
      relic = create(:relic, :without_description)

      visit relic_path(relic.id)
      page.should have_content("Nikt nie napisał jeszcze opisu dla tego zabytku")
      page.should have_content("Zrób to Ty!")
      page.should have_link("dodaj opis", :title => "dodaj opis do zabytku", :href => edit_section_relic_path(relic.id, :description))
    end

    it "should display link to edit description if it's present" do
      relic = create(:relic)

      visit relic_path(relic.id)
      page.should have_link("edytuj", :title => "edytuj opis zabytku", :href => edit_section_relic_path(relic.id, :description))
    end
  end
  
  describe "GET /relic/1/edit/description" do
    it "should redirect to login page when no user is logged in" do
      relic = create(:relic)

      visit edit_section_relic_path(relic.id, :description)
      page.should have_css('form#new_user')
    end

    it "should redirect back to editing description after logging in" do
      user = create(:registered_user)
      relic = create(:relic)

      visit edit_section_relic_path(relic.id, :description)
      fill_in 'Adres e-mail', :with => user.email
      fill_in 'Hasło', :with => user.password
      click_on 'Zaloguj się'

      page.should have_css('section.description form')
    end

    it "should not redirect if user have logged in before" do
      login_as(create(:registered_user))
      visit edit_section_relic_path(create(:relic).id, :description)
      page.should have_css('section.description form')
    end

    it "should change relic description after filling the form" do
      login_as(create(:registered_user))
      visit edit_section_relic_path(create(:relic).id, :description)
      page.should have_css('section.description form')
      fill_in('relic[description]', :with => 'This is new description of this Relic.')
      click_on('zapisz')

      page.should have_content('This is new description of this Relic.')
      page.should_not have_css('input[name="relic[description]"]')
    end
  end

end
