# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Import::AdministrativeDivision do
  describe "find_or_create" do

    it "should rise error for wrong arguments" do
      expect{ Import::AdministrativeDivision.find_or_create('a', 'b') }.to raise_error(ArgumentError)
      expect{ Import::AdministrativeDivision.find_or_create('a', nil, '', 'c') }.to raise_error(ArgumentError)
    end

    it "should create and return place" do
      Place.find_by_name('Wrocław').should be_nil
      place = Import::AdministrativeDivision.find_or_create('dolnoslaskie', 'wrocławski', 'Wrocław', 'Wrocław')
      place.should eq(Place.find_by_name('Wrocław'))
    end

    it "should find the same place for the same arguments" do
      place1 = Import::AdministrativeDivision.find_or_create('dolnoslaskie', 'wrocławski', 'Wrocław', 'Wrocław')
      palces_count = [Voivodeship.count, District.count, Commune.count, Place.count]
      place2 = Import::AdministrativeDivision.find_or_create('dolnoslaskie', 'wrocławski', 'Wrocław', 'Wrocław')
      palces_count.should eq([Voivodeship.count, District.count, Commune.count, Place.count])
      place1.should eq(place2)
    end

  end
end
