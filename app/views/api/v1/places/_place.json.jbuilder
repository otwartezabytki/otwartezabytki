json.id place.id
json.name place.name
json.full_name place.location_names

if params[:include_details]
  json.commune do |json|
    json.partial! "api/v1/communes/commune", :commune => place.commune
  end
end
