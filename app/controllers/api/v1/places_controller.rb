# -*- encoding : utf-8 -*-
module Api
  module V1
    class PlacesController < ApiController
      before_filter :api_authenticate

      def index
        @places = []
        @places = if params[:q].present?
          Place.search(params[:q]).page(params[:page]).per(20)
        end
        render json: @places
      end
    end
  end
end
