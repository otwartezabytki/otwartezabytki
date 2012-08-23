json.id commune[:id]
json.name commune[:name]

if params[:include_details]
  json.district do |json|
    json.partial! "api/v1/districts/district", :district => commune.district
  end
end

