# -*- encoding : utf-8 -*-
module Api
  module V1
    class PlacesController < ApiController
      before_filter :api_authenticate

      def index
        @places = Place.search(params[:query]).page(params[:page]).per(20)
      end
    end
  end
end
