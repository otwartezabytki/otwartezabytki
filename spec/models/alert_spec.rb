# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Alert do
  it "should belong to relic and user" do
    build(:alert).should respond_to(:user)
    build(:alert).should respond_to(:relic)
  end
end
