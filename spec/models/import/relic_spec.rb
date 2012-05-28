# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Import::Relic do
  describe "parse" do

    it "should create relics for valid_relics.csv" do
      Relic.count.should eq(0)
      Import::Relic.parse sample_path('valid_relics.csv')
      Relic.count.should eq(3)
    end

    # it "should update relics for valid_relics.csv" do
    #   Import::Relic.parse sample_path('valid_relics.csv')
    #   Relic.count.should eq(3)
    #   Import::Relic.parse sample_path('valid_updated_relics.csv')
    #   Relic.count.should eq(3)
    #   Relic.all.each { |r| r.updated_at.should > r.created_at }
    # end

    it "should skip already created relics" do
      Import::Relic.parse sample_path('valid_relics.csv')
      Relic.count.should eq(3)
      Import::Relic.parse sample_path('valid_relics.csv')
      Relic.count.should eq(3)
      Relic.all.each { |r| r.updated_at.should == r.created_at }
    end
  end

end
