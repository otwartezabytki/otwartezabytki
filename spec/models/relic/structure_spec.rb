require 'spec_helper'

describe Relic do
  it "should have symmetric documents relation" do
    create(:relic).should respond_to(:documents)
    create(:document).should respond_to(:relic)
  end

  it "should have symmetric photos relation" do
    create(:relic).should respond_to(:photos)
    create(:photo).should respond_to(:relic)
  end

  it "should have description field" do
    create(:relic).should respond_to(:description)
  end

  it "should have symmetric alerts relation" do
    create(:relic).should respond_to(:alerts)
    create(:alert).should respond_to(:relic)
  end

  it "should have symmetric entries relation" do
    create(:relic).should respond_to(:entries)
    create(:entry).should respond_to(:relic)
  end
end