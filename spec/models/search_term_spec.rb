# -*- encoding : utf-8 -*-
require 'spec_helper'

describe SearchTerm do
  context "store keyword" do
    it "should return false for blank? string" do
      SearchTerm.store(nil).should    be_false
      SearchTerm.store("   ").should  be_false
      SearchTerm.store(' *').should   be_false
    end

    it "should create new entry for non existing keyword" do
      lambda {
        SearchTerm.store('some keyword')
      }.should change(SearchTerm, :count).by(1)
    end

    it "should increment keyword counter for existing one" do
      SearchTerm.store('some keyword')
      lambda {
        SearchTerm.store('some keyword')
      }.should_not change(SearchTerm, :count)

      SearchTerm.find_by_keyword('some keyword').count.should eq 2
    end
  end
end
