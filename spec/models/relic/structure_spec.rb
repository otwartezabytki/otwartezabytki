# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Relic do
  it "should have symmetric documents relation" do
    build(:relic).should respond_to(:documents)
    build(:document).should respond_to(:relic)
  end

  it "should have symmetric photos relation" do
    build(:relic).should respond_to(:photos)
    build(:photo).should respond_to(:relic)
  end

  it "should have description field" do
    build(:relic).should respond_to(:description)
  end

  it "should have symmetric alerts relation" do
    build(:relic).should respond_to(:alerts)
    build(:alert).should respond_to(:relic)
  end

  it "should have symmetric entries relation" do
    build(:relic).should respond_to(:entries)
    build(:entry).should respond_to(:relic)
  end

  it "should have symmetric links relation" do
    build(:relic).should respond_to(:links)
    build(:link).should respond_to(:relic)
  end

  it "should have symmetric events relation" do
    build(:relic).should respond_to(:events)
    build(:event).should respond_to(:relic)
  end

  it "should have accessible both tags and categories" do
    build(:relic).should have_accessible(:tags)
    build(:relic).should have_accessible(:categories)
  end

  it "should have tags and categories as arrays" do
    build(:relic).tags.should be_a(Array)
    build(:relic).categories.should be_a(Array)
  end
end
