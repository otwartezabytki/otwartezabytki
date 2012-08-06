# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "Home" do
  describe "GET /" do
    it "should return 200 status code for anonymous user" do
      visit('/')
      page.status_code.should be(200)
    end
  end
end