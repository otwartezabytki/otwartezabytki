# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Relic do
  it { should belong_to :place }
  it { should belong_to :district }
  it { should belong_to :commune }
  it { should belong_to :voivodeship }

  context "regarding saving it's previous state" do
    it "should have only one version at beginning" do
      relic = create :relic
      relic.versions.count.should eq 0
    end

    it "should create new version each time it's modified" do
      relic = create :relic
      relic.update_attributes(:identification => "new identification")
      relic.versions.count.should eq 1
      relic.update_attributes(:place_id => create(:place).id)
      relic.versions.count.should eq 2
    end

    it "should crate new version if it's reifed to previous version" do
      relic = create :relic
      relic_name = relic.identification
      relic.update_attributes(:identification => "new identification")
      relic = relic.versions.last.reify
      relic.save!
      relic.identification.should eq relic_name
      relic.versions.count.should eq 2
    end
  end

  context "reindex some relics" do
    it "recreate index structure and index relics" do
      r1, r2 = create(:relic), create(:relic)
      Relic.index.delete
      Relic.index.should_not exist

      Relic.reindex [r1, r2]

      Relic.tire.search('*').total.should eq 2
      Relic.index.should exist
    end
  end

  context "relic correctness" do
    it "should be corrected when has more than 3 suggestions" do
      relic = create(:relic)
      4.times { relic.suggestions.create :identification => 'Pałac zamkowy' }
      relic.should be_corrected
    end

    it "should be incorect for new created relics" do
      relic = create(:relic)
      relic.should_not be_corrected
    end

    it "should be corected if an user make suggestion" do
      relic = create(:relic)
      user = create(:user)
      relic.suggestions.create :identification => 'Pałac zamkowy', :user => user
      relic.corrected_by?(user).should be_true
    end
  end

  context "place_full_name" do
    it "should return place full location" do
      relic = create(:relic)
      3.times { create(:relic, :parent => relic) }
      relic.place_full_name.should match %r(#{relic.voivodeship.name})
    end
  end

end
