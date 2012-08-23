# -*- encoding : utf-8 -*-
module Api
  module V1
    class InfosController < ApiController
      def show
        respond_with({
          :apiVersion => "1.0",
          :apis => [
            {
              :description => "Relics",
              :path => "/relics.{format}"
            },
            {
              :description => "Places",
              :path => "/places.{format}"
            }
          ],
          :basePath => "http://otwartezabytki.dev/api/v1/info",
          :swaggerVersion => "1.1"
        })
      end

      def relics
        respond_with({
          :apiVersion => "1.0",
          :basePath => "http://otwartezabytki.dev/api/v1",
          :resourcePath => "/relics",
          :swaggerVersion => "1.1",
          :apis => [{
            :description => "Operations on relics",
            :operations => [{
              :httpMethod => "GET",
              :nickname => "SearchRelics",
              :notes => "Search relics",
              :parameters => [{
                :allowMultiple => false,
                :dataType => "string",
                :description => "Search query",
                :name => "query",
                :paramType => "query",
                :required => false
              },{
                :allowMultiple => false,
                :dataType => "int",
                :description => "Page",
                :name => "page",
                :paramType => "query",
                :required => false
              }],
              :responseClass => "Relic",
              :summary => "Search relics"
            },{
              :httpMethod => "POST",
              :nickname => "CreateRelic",
              :notes => "Create new relic",
              :parameters => [{
                :allowMultiple => false,
                :dataType => "Relic",
                :description => "Relic json data (place_id, identification, description)",
                :name => "relic",
                :paramType => "body",
                :required => true,
                :defaultValue => <<-EOS
{
  "place_id": 10,
  "identification": "Cmentarz",
  "description": "Bardzo piekny"
}
                EOS
              },{
                :allowMultiple => false,
                :dataType => "string",
                :description => "API Secret",
                :name => "api_secret",
                :paramType => "query",
                :required => true
              }],
              :responseClass => "Relic",
              :summary => "Create new relic"
            }],
            :path => "/relics.{format}"
          },{
            :description => "Operations on relics",
            :operations => [
              :httpMethod => "GET",
              :nickname => "GetRelicByID",
              :notes => "Returns a relic based on ID",
              :parameters => [{
                :allowMultiple => false,
                :dataType => "int",
                :description => "Relic ID",
                :name => "id",
                :paramType => "path",
                :required => true
              }],
              :responseClass => "Relic",
              :summary => "Get relic by ID",
              :errorResponses => [{
                :code => 404,
                :reason => "The relic cannot be found"
              }]
            ],
            :path => "/relics/{id}.{format}"
          }],
          :models => {
            "Relic" => {
              :id => "Relic",
              :properties => {
                :id => { :type => "long" },
                :name => { :type => "string" }
              }
            }
          }
        })
      end

      def places
        respond_with({
          :apiVersion => "1.0",
          :basePath => "http://otwartezabytki.dev/api/v1",
          :resourcePath => "/places",
          :swaggerVersion => "1.1",
          :apis => [{
            :description => "Operations on places",
            :operations => [{
              :httpMethod => "GET",
              :nickname => "SearchPlaces",
              :notes => "Search places",
              :parameters => [{
                :allowMultiple => false,
                :dataType => "string",
                :description => "Search query",
                :name => "query",
                :paramType => "query",
                :required => false
              },{
                :allowMultiple => false,
                :dataType => "boolean",
                :description => "Include details?",
                :name => "include_details",
                :paramType => "query",
                :required => false
              },{
                :allowMultiple => false,
                :dataType => "int",
                :description => "Page",
                :name => "page",
                :paramType => "query",
                :required => false
              }],
              :responseClass => "Place",
              :summary => "Search places"
            }],
            :path => "/places.{format}"
          }],
          :models => {
            "Place" => {
              :id => "Place",
              :properties => {
                :id => { :type => "long" },
                :name => { :type => "string" }
              }
            }
          }
        })
      end

    end
  end
end
