# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "Relics" do
  describe "GET /relic" do
    it "should return success status code for existing relic" do
      relic = create(:relic)
      visit relic_path(relic.id)
      page.status_code.should be(200)
    end

    it "should throw ActiveRecord::RecordNotFound for non-existent relic" do
      relic = create(:relic)

      expect {
        visit relic_path(relic.id + 1)
      }.to raise_exception(ActiveRecord::RecordNotFound)
    end

    it "should contain sections along with given titles" do
      relic = create(:relic)
      visit relic_path(relic.id)

      page.should have_content("Opis")
      page.should have_content("Społeczność")
      page.should have_content("Linki, źródła, powiązania")
      page.should have_content("Dokumenty urzędowe")
      page.should have_content("Lokalizacja")
    end

    it "should contain relic identification" do
      relic = create(:relic)
      visit relic_path(relic.id)
      page.should have_content(relic.identification)
    end

    it "should contain relic register number" do
      relic = create(:relic)
      visit relic_path(relic.id)
      page.should have_content("Numer w rejestrze: " + relic.register_number)
    end

    it "should contain voivodeship, district and commune name" do
      relic = create(:relic)
      visit relic_path(relic.id)
      page.should have_content("#{relic.place.name}, powiat #{relic.district.name}, gmina #{relic.commune.name}")
      page.should have_content("#{relic.street}")
    end

    it "should contain list of categories" do
      relic = create(:relic)
      relic.categories.should_not be_blank

      visit relic_path(relic.id)

      relic.categories.each do |category|
        page.should have_content(category)
      end
    end

    it "should contain list of tags" do
      relic = create(:relic)
      relic.tags.should_not be_blank

      visit relic_path(relic.id)

      relic.tags.each do |category|
        page.should have_content(category)
      end
    end

    it "should display message and button for adding tags it they are not present" do
      relic = create(:relic, :without_tags)

      visit relic_path(relic.id)
      page.should have_content("nie dodano żadnych, dodaj pierwszy!")
      page.should have_link("otaguj zabytek", :href => edit_section_relic_path(relic.id, :tags))
    end

    it "should display all entries of users" do
      relic = create(:relic_with_entries)

      visit relic_path(relic.id)

      relic.entries.each do |entry|
        page.should have_content(entry.title)
        page.should have_content(entry.body)
        page.should have_content(entry.body)
      end
    end

    it "entries should have properly formatted date" do
      relic = create(:relic_with_entries)
      relic.entries.first.update_attribute(:created_at, Time.parse("1991-06-29 17:18"))

      visit relic_path(relic.id)

      page.should have_content("29.06.1991, 17:18")
    end

    it "should display relic coordinated rounded to 6 decimal places" do
      relic = create(:relic)
      visit relic_path(relic.id)

      page.should have_content(relic.latitude.round(6).to_s + ", " + relic.longitude.round(6).to_s)
    end

    it "should display 4 most recent photos" do
      relic = create(:relic_with_photos)

      visit relic_path(relic.id)

      relic.photos.each do |photo|
        page.should have_css("a[href='#{show_gallery_relic_path(relic.id, photo.id)}']")
        page.should have_css("img[src='#{photo.file.thumb.url}']")
      end
    end

    it "should have link to gallery along with number of photos" do
      relic = create(:relic_with_photos)
      visit relic_path(relic.id)

      page.should have_link("galeria (#{relic.photos.count})", :href => show_gallery_relic_path(relic.id))
    end
  end
end
