json.id place[:id]
json.name place[:name]
json.full_name place[:full_name] if place[:full_name]
json.with_address place[:with_address] if place[:with_address]

if params[:include_details]
  json.commune do |json|
    json.partial! "api/v1/communes/commune", :commune => place.commune
  end
end
