# -*- encoding : utf-8 -*-
require 'spec_helper'

describe RelicsController do

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # RelicsController. Be sure to keep this updated too.
  def valid_session
    {}
  end

  describe "GET index" do
    it "assigns all relics as @relics" do
      relic = create :relic
      refresh_relics_index
      get :index, {}, valid_session
      exposed(:relics).results.should eq [relic]
    end
  end

  describe "GET show" do
    it "assigns the requested relic as @relic" do
      relic = create :relic
      get :show, {:id => relic.to_param}, valid_session
      exposed(:relic).should eq relic
    end
  end

  describe "GET edit" do
    it "assigns the requested relic as @relic" do
      relic = create :relic
      get :edit, {:id => relic.to_param}, valid_session
      exposed(:relic).should eq relic
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested relic" do
        relic = create :relic
        # Assuming there are no other relics in the database, this
        # specifies that the Relic created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Relic.any_instance.should_receive(:update_attributes).with({'identification' => 'New Identification'})
        put :update, { :id => relic.to_param, :relic => { :identification => 'New Identification'} }, valid_session
      end

      it "assigns the requested relic as @relic" do
        relic = create :relic
        put :update, { :id => relic.to_param, :relic => { :identification => 'New Identification'} }, valid_session
        exposed(:relic).should eq(relic)
      end

      it "redirects to the relic" do
        relic = create :relic
        put :update, { :id => relic.to_param, :relic => { :identification => 'New Identification'} }, valid_session
        response.should redirect_to(relic)
      end
    end

    describe "with invalid params" do
      it "assigns the relic as @relic" do
        relic = create :relic
        # Trigger the behavior that occurs when invalid params are submitted
        Relic.any_instance.stub(:save).and_return(false)
        put :update, {:id => relic.to_param, :relic => { :place_id => 666 }}, valid_session
        exposed(:relic).should eq(relic)
      end

      it "re-renders the 'edit' template" do
        relic = create :relic
        # Trigger the behavior that occurs when invalid params are submitted
        Relic.any_instance.stub(:save).and_return(false)
        put :update, {:id => relic.to_param, :relic => { :place_id => 666 }}, valid_session
        response.should render_template("edit")
      end
    end
  end

end
