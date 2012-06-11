# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Relic do
  it { should belong_to :place }
  it { should belong_to :district }
  it { should belong_to :commune }
  it { should belong_to :voivodeship }

  context "regarding place caching fields" do
    it "should update them when place_id is modified" do
      relic = create :relic, :in_bardo
      leszno = create :place_leszno
      magdalenowo = create :place_magdalenowo

      # update by association
      relic.place = leszno
      relic.place_id.should eq leszno.id
      relic.commune_id.should eq leszno.commune.id
      relic.district_id.should eq leszno.commune.district.id
      relic.voivodeship_id.should eq leszno.commune.district.voivodeship.id

      # update by ID attribute
      relic.place_id = magdalenowo.id
      relic.commune_id.should eq magdalenowo.commune.id
      relic.district_id.should eq magdalenowo.commune.district.id
      relic.voivodeship_id.should eq magdalenowo.commune.district.voivodeship.id

      # update by update_attributes
      relic.update_attributes(:place_id => leszno.id)
      relic.place_id.should eq leszno.id
      relic.commune_id.should eq leszno.commune.id
      relic.district_id.should eq leszno.commune.district.id
      relic.voivodeship_id.should eq leszno.commune.district.voivodeship.id
    end

    it "should prevent them to be modified by update_attributes" do
      relic = create :relic, :in_bardo
      bardo = relic.place
      magdalenowo = create :place_magdalenowo
      leszno = create :place_leszno

      # modify only caching fields
      expect {
        relic.update_attributes(
          :commune_id => leszno.commune.id,
          :district_id => leszno.commune.district.id,
          :voivodeship_id => leszno.commune.district.voivodeship.id
        )
      }.to raise_error

      # modify caching fields and place_id
      expect {
        relic.update_attributes(
          :place_id => magdalenowo.id,
          :commune_id => leszno.commune.id,
          :district_id => leszno.commune.district.id,
          :voivodeship_id => leszno.commune.district.voivodeship.id
        )
      }.to raise_error

      # should pass
      relic.update_attributes(:place_id => magdalenowo.id)
    end
  end

  context "regarding saving it's previous state" do
    it "should have only one version at beginning" do
      relic = create :relic
      relic.versions.count.should eq 1
    end

    it "should create new version each time it's modified" do
      relic = create :relic
      relic.update_attributes(:identification => "new identification")
      relic.versions.count.should eq 2
      relic.update_attributes(:place_id => create(:place).id)
      relic.versions.count.should eq 3
    end

    it "should crate new version if it's reifed to previous version" do
      relic = create :relic
      relic_name = relic.identification

      relic.update_attributes(:identification => "new identification")
      relic = relic.versions.last.reify
      relic.save!
      relic.identification.should eq relic_name
      relic.versions.count.should eq 3
    end
  end

end
