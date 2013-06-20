require 'spec_helper'

module Api
  module V1
    describe PhotosController, type: :controller do
      context '#index' do
        it 'assigns @photos' do
          photo = FactoryGirl.create(:photo)
          get :index, relic_id: photo.relic_id, api_key: photo.user.api_key
          controller.photos.should eq([photo])
          expect(response.code).to eq("200")
        end

        it 'renders :index' do
          photo = FactoryGirl.create(:photo)
          get :index, relic_id: photo.relic_id, api_key: photo.user.api_key
          response.should render_template("index")
        end
      end

      context '#show' do
        let(:photo) { FactoryGirl.create(:photo) }

        it 'assigns @photo' do
          get :show, id: photo.id, relic_id: photo.relic_id, api_key: photo.user.api_key
          controller.photo.should.should eq(photo)
          expect(response.code).to eq("200")
        end

        it 'renders :show' do
          get :show, id: photo.id, relic_id: photo.relic_id, api_key: photo.user.api_key
          response.should render_template("show")
        end

        it 'raises 404 error when accessing unknown photo' do
          get :show, id: 42, relic_id: photo.relic_id, api_key: photo.user.api_key
          expect(response.code).to eq("404")
        end
      end

      context '#create' do
        let(:photo_attributes) { FactoryGirl.attributes_for(:uploaded_photo) }
        let(:invalid_photo_attributes) { photo_attributes.delete_if{ |key, _| key == :file } }
        let(:relic) { FactoryGirl.create(:relic) }
        let(:user) { FactoryGirl.create(:api_user) }

        it 'creates new photo' do
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

        it 'should not create new photo' do
          # require'pry';binding.pry
          expect do
            post :create, {
              relic_id: relic.id,
              api_key: user.api_key,
              api_secret: user.api_secret,
              photo: invalid_photo_attributes
            }
            expect(response.code).to eq("422")
          end.not_to change{ Photo.count }
        end
      end

      context '#update' do
        let(:photo) { FactoryGirl.create(:photo) }
        photo_attributes = { author: 'John Doe', date_taken: '2010-01-01' }
        invalid_photo_attributes = { author: '' }

        it 'updates photo' do
          # require'pry';binding.pry
          put :update, {
            relic_id: photo.relic_id,
            id: photo.id,
            api_key: photo.user.api_key,
            api_secret: photo.user.api_secret,
            photo: photo_attributes
          }
          photo.reload
          photo.author.should == 'John Doe'
          photo.date_taken.should == '2010-01-01'
          expect(response.code).to eq("200")
        end

        it 'should not update photo ' do
          # require'pry';binding.pry
          prev_updated_at = photo.updated_at.dup
          put :update,
            relic_id: photo.relic_id,
            id: photo.id,
            api_key: photo.user.api_key,
            api_secret: photo.user.api_secret,
            photo: invalid_photo_attributes
          photo.reload
          photo.updated_at.to_s.should == prev_updated_at.to_s
          expect(response.code).to eq("422")
        end
      end
    end
  end
end
