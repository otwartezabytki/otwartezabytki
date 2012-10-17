# -*- encoding : utf-8 -*-
module Api
  module V1
    class UsersController < ApiController
      before_filter :simple_authorize

      def api_key_request
        @user.ensure_api_keys_generated!
      end

      protected
        def simple_authorize
          # email and password should be Base64.urlsafe encoded
          # http://apidock.com/ruby/Base64/urlsafe_decode64
          authenticate_or_request_with_http_basic do |email, password|
            email     = Base64.urlsafe_decode64(email)    rescue nil
            password  = Base64.urlsafe_decode64(password) rescue nil
            @user = User.find_by_email(email)
            @user && @user.valid_password?(password)
          end
        end
    end
  end
end
