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
end