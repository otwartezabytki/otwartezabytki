require 'spec_helper'

module Api
  module V1
    describe PhotosController, type: :controller do
      context '#index' do
        it 'assigns @photos' do
          photo = FactoryGirl.create(:photo)
          get :index, relic_id: photo.relic_id
          controller.photos.should eq([photo])
          expect(response.code).to eq("200")
        end

        it 'renders :index' do
          photo = FactoryGirl.create(:photo)
          get :index, relic_id: photo.relic_id
          response.should render_template("index")
        end
      end

      context '#show' do
        let(:photo) { FactoryGirl.create(:photo) }

        it 'assigns @photo' do
          get :show, id: photo.id, relic_id: photo.relic_id
          controller.photo.should.should eq(photo)
          expect(response.code).to eq("200")
        end

        it 'renders :show' do
          get :show, id: photo.id, relic_id: photo.relic_id
          response.should render_template("show")
        end

        it 'raises 404 error when accessing unknown photo' do
          get :show, id: 42, relic_id: photo.relic_id
          expect(response.code).to eq("404")
        end
      end

      context '#create' do
        let(:photo_attributes) { FactoryGirl.attributes_for(:uploaded_photo) }
        let(:invalid_photo_attribues) { photo_attributes.delete_if{ |key, _| key == "file" } }
        let(:relic) { FactoryGirl.create(:relic) }
        let(:user) { FactoryGirl.create(:api_user) }

        it 'creates new photo', focus: true do
          expect do
            post :create, {
              relic_id: relic.id,
              api_key: user.api_key,
              api_secret: user.api_secret,
              photo: photo_attributes
            }

            response.body.should =~ /#{photo_attributes[:name]}/
            expect(response.code).to eq("200")
          end.to change{ Photo.count }.by(1)
        end

        it 'creates new photo', focus: true do
          require'pry';binding.pry
          require'pry';binding.pry
          expect do
            post :create, {
              relic_id: relic.id,
              api_key: user.api_key,
              api_secret: user.api_secret,
              photo: invalid_photo_attributes
            }

            expect(response.code).to eq("404")
          end.to not_change{ Photo.count }
        end
      end
    end
  end
end
