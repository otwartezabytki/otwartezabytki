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
      exposed(:relics).results.size.should eq 1
      exposed(:relics).results.map(&:id).should eq [relic.id.to_s]
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
      it "creates new suggestion instead of modyfying relic" do
        relic = create :relic
        old_identification = relic.identification
        Suggestion.count.should eq 0
        put :update, { :id => relic.to_param, :suggestion => { :identification => 'New Identification' } }, valid_session
        Suggestion.count.should eq 1
        relic.reload.identification.should eq old_identification
        exposed(:suggestion).should eq(Suggestion.first)
      end

      it "redirects to the thank you page" do
        relic = create :relic
        put :update, { :id => relic.to_param, :suggestion => { :identification => 'New Identification'} }, valid_session
        response.should redirect_to([:gonext, relic])
      end

      it "should remember ip address of sender" do
        relic = create :relic
        put :update, {
          :id => relic.to_param,
          :suggestion => { :identification => 'New Identification' }
        }
        exposed(:suggestion).ip_address.should eq('0.0.0.0')
      end
    end

    describe "with invalid params" do
      it "assigns the relic as @relic" do
        relic = create :relic
        # Trigger the behavior that occurs when invalid params are submitted
        Suggestion.any_instance.stub(:save).and_return(false)
        put :update, {:id => relic.to_param, :suggestion => { :place_id => 666 }}, valid_session
        exposed(:relic).should eq(relic)
      end

      it "re-renders the 'edit' template" do
        relic = create :relic
        # Trigger the behavior that occurs when invalid params are submitted
        Suggestion.any_instance.stub(:save).and_return(false)
        put :update, {:id => relic.to_param, :suggestion => { :place_id => 666 }}, valid_session
        response.should render_template("edit")
      end
    end
  end

end
