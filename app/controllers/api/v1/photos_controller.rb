# -*- encoding : utf-8 -*-
module Api
  module V1
    class PhotosController < ApiController
      before_filter :api_authenticate
      before_filter :api_authorize, :only => [:create, :update, :destroy]

      expose(:relic)
      expose(:photos, ancestor: :relic)
      expose!(:photo, strategy: StrongParametersStrategy)

      def create
        authorize!(:create, photo)
        photo.user_id = api_user.id

        if photo.save
          render :show
        else
          render :json => {:errors => photo.errors}, :status => :unprocessable_entity
        end
      end

      def update
        authorize!(:update, photo)
        photo.user_id = api_user.id

        if photo.save
          render :show
        else
          render :json => {:errors => photo.errors}, :status => :unprocessable_entity
        end
      end

      def destroy
        authorize!(:destroy, photo)
        photo.destroy
        respond_with(photo)
      end

      private

      def photo_params
        params.require(:photo).permit(:author, :date_taken, :file)
      end
    end
  end
end

