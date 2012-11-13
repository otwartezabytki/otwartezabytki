# -*- encoding : utf-8 -*-

require 'spec_helper'

describe GeocoderController do

  describe "GET 'search'" do
    it "search by query" do
      get 'search', :query => "Dolnośląskie, Wrocław, Wrocław, Brossa 5"
      response.should be_success
    end

    it "search by commune, district and voivodeship" do
      get 'search', :voivodeship => "dolnośląskie", :district => "Kłodzki", :commune => "radków"
      response.should be_success
    end

    it "search by street, city, commune, district and voivodeship" do
      get 'search', :voivodeship => "dolnośląskie", :district => "Kłodzki", :commune => "radków",
                    :city => "Scinawka Srednia", :street => "Wojska Polskiego 6"

      response.should be_success
    end
  end

end
