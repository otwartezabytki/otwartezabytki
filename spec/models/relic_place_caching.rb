# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Relic do
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
end
