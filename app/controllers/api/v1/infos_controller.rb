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
          :basePath => "http://#{Settings.oz.host}/api/v1/info",
          :swaggerVersion => "1.1"
        })
      end

      def relics
        respond_with({
          :apiVersion => "1.0",
          :basePath => "http://#{Settings.oz.host}/api/v1",
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
                :dataType => "string",
                :description => "Place",
                :name => "place",
                :paramType => "query",
                :required => false
              },{
                :allowMultiple => false,
                :dataType => "string",
                :description => "From",
                :name => "from",
                :paramType => "query",
                :required => false
              },{
                :allowMultiple => false,
                :dataType => "string",
                :description => "To",
                :name => "to",
                :paramType => "query",
                :required => false
              },{
                :allowMultiple => false,
                :dataType => "boolean",
                :description => "Include descendants?",
                :name => "include_descendants",
                :paramType => "query",
                :required => false
              },{
                :allowMultiple => false,
                :dataType => "boolean",
                :description => "Has photos?",
                :name => "has_photos",
                :paramType => "query",
                :required => false
              },{
                :allowMultiple => false,
                :dataType => "boolean",
                :description => "Has description?",
                :name => "has_description",
                :paramType => "query",
                :required => false
              },{
                :allowMultiple => false,
                :dataType => "string",
                :allowableValues => {
                  :valueType => "LIST",
                  :values => ['score.asc', 'score.desc', 'alfabethic.asc', 'alfabethic.desc'],
                },
                :description => "Order",
                :name => "order",
                :paramType => "query",
                :required => false
              },{
                :allowMultiple => true,
                :dataType => "Array",
                :defaultValue => Category.all.keys,
                :description => "Categories (comma separated)",
                :name => "categories",
                :paramType => "query",
                :required => false
              },{
                :allowMultiple => true,
                :dataType => "Array",
                :defaultValue => Relic::States,
                :description => "State (comma separated)",
                :name => "state",
                :paramType => "query",
                :required => false
              },{
                :allowMultiple => true,
                :dataType => "Array",
                :defaultValue => Relic::Existences,
                :description => "Existence (comma separated)",
                :name => "existence",
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
              :notes => "Create new relic<br/>
                <strong>Required relic parameters:</strong> place_id, identification, description, reason<br/>
                <strong>Optional relic parameters:</strong> parent_id, latitude, longitude, number, dating_of_obj,
                  street, register_number, categories, tags, country_code, fprovinde, fplace, document_info, links_info
              ",
              :parameters => [{
                :allowMultiple => false,
                :dataType => "Relic",
                :description => "Relic json data",
                :name => "relic",
                :paramType => "body",
                :required => true,
                :defaultValue => <<-EOS
{
  "place_id": 10,
  "identification": "Suler",
  "description": "CEO",
  "reason": "You tell me ..."
  "latitude": 0.0,
  "longitude": 0.0,
  "number": 1,
  "dating_of_obj": "ok. 1600",
  "street": "Brossa 5",
  "register_number": "??",
  "categories": "",
  "tags": "",
  "country_code": "PL",
  "fprovinde": "",
  "fplace": "",
  "document_info": "",
  "links_info": ""
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
          :basePath => "http://#{Settings.oz.host}/api/v1",
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
