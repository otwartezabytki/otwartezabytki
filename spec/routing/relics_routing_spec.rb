# -*- encoding : utf-8 -*-
require "spec_helper"

describe RelicsController do
  describe "routing" do

    it "routes to #index" do
      get("/relics").should route_to("relics#index")
    end

    it "routes to #show" do
      get("/relics/1").should route_to("relics#show", :id => "1")
    end

    it "routes to #update" do
      put("/relics/1").should route_to("relics#update", :id => "1")
    end

    it "routes to #edit with general_info as section" do
      get("/relics/1/edit/general_info").should route_to("relics#edit", :id => "1", :section => "general_info")
    end

    it "routes to #edit with description as section" do
      get("/relics/1/edit/description").should route_to("relics#edit", :id => "1", :section => "description")
    end
  end
end
