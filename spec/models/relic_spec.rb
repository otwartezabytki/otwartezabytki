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

end
