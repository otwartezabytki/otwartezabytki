json.id district.id
json.name district.name

if params[:include_details]
  json.voivodeship do |json|
    json.partial! "api/v1/voivodeships/voivodeship", :voivodeship => district.voivodeship
  end
end
