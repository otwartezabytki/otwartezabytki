# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "Relics" do
  setup do
    refresh_relics_index
  end

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

    it "should contain relic identification" do
      relic = create(:relic)
      visit relic_path(relic.id)
      page.should have_content(relic.identification)
    end
  end
end
