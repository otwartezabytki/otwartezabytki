module Api
  module V1
    class ApiController < ApplicationController
      respond_to :json

      rescue_from ActiveRecord::RecordNotFound, :with => :not_found

      def not_found
        render :json => {:error => "Not found"}, :status => :not_found
      end

      protected

      # API auth example:
      #
      # before_filter :api_authenticate
      # before_filter :api_authorize, :only => [:create]

      # Check api_key
      def api_authenticate
        unless api_user
          render :json => {:error => "API key not found"}, :status => :unauthorized
        end
      end

      # Check api_key AND api_secret
      def api_authorize
        api_authenticate

        unless api_user.api_secret && api_user.api_secret == params[:api_secret]
          render :json => {:error => "API secret mismatch"}, :status => :unauthorized
        end
      end

      def api_user
        @api_user ||= User.find_by_api_key(params[:api_key])
      end

      def user_for_paper_trail
        api_user
      end

      def info_for_paper_trail
        if api_user
          {:source => "API: #{api_user.api_key}"}
        else
          {}
        end
      end
    end
  end
end
