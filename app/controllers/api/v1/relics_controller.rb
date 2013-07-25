# -*- encoding : utf-8 -*-
module Api
  module V1
    class RelicsController < ApiController

      before_filter :api_authenticate
      before_filter :api_authorize, :only => [:create, :update]

      def index
        p = params.slice(:query, :place, :from, :to, :categories, :state, :existence, :location, :has_photos, :has_description, :order, :latitude, :longitude, :bounding_box, :path, :radius)

        [:state, :existence].each do |key|
          if p[key] && !p[key].is_a?(Array)
            p[key] = p.delete(key).split(",")
          end
        end

        p[:lat] = p.delete(:latitude) if p[:latitude]
        p[:lon] = p.delete(:longitude) if p[:longitude]

        params[:search] = p.merge(:q => p.delete(:query))

        tsearch.load = true
        @relics = tsearch.perform
      end

      def show
        @relic = Relic.find(params[:id])
      end

      def create
        # TODO (missing model fields)
        params[:relic].delete(:state)
        # ----



        @relic = Relic.new(params[:relic])
        @relic.user_id = api_user.id
        @relic.created_via_api = true
        @relic.parent_id = params[:relic][:parent_id]
        @relic.reason = params[:relic][:reason]


        if @relic.save
          render :show
        else
          render :json => {:errors => @relic.errors}, :status => :unprocessable_entity
        end
      end

      def update
        @relic = Relic.find(params[:id])
        @relic.user_id = api_user.id

        if @relic.update_attributes(params[:relic])
          render :show
        else
          render :json => {:errors => @relic.errors}, :status => :unprocessable_entity
        end
      end

    end
  end
end

