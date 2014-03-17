json.selected do
  json.voivodeship(@voivodeship, :id, :name)  if @voivodeship
  json.district(@district, :id, :name)        if @district
  json.commune do |json|
    json.id   @commune.virtual_id
    json.name @commune.name
  end if @commune
  json.place(@place, :id, :name)              if @place
end

json.voivodeships(@voivodeships, :id, :name)
json.districts(@districts , :id, :name)
json.communes do |json|
  json.array!(@communes) do |json, commune|
    json.id   commune.virtual_id
    json.name commune.name
  end.uniq
end
json.places(@places , :id, :name)
