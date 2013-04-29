json.photos do |json|
  json.array!(photos) do |json, photo|
    json.partial! "api/v1/photos/photo", :photo => photo
  end
end