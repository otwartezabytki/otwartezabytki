# -*- encoding : utf-8 -*-
require 'spec_helper'

describe RelicsController do

  context "as anonymous user" do
    describe "GET index" do
      it "assigns all relics as @relics" do
        relic = create :relic
        refresh_relics_index
        get :index, {}
        exposed(:relics).results.size.should eq Relic.count
        exposed(:relics).results.map(&:id).should eq Relic.all.map(&:id).map(&:to_s)
      end
    end

    describe "GET edit" do
      it "should redirect to login page if no user is logged in" do
        relic = create :relic

        # don't pass valid session
        get :edit, {:id => relic.to_param}
        response.should redirect_to(new_user_session_path)
      end
    end
  end

  context "as registered user" do
    login_user

    describe "GET edit" do
      it "assigns the requested relic as @relic" do
        relic = create :relic
        get :edit, { :id => relic.to_param, :section => :description }
        exposed(:relic).should eq relic
        response.should_not redirect_to(new_user_session_path)
      end
    end
  end

end
