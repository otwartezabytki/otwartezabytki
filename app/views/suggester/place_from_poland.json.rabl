collection @places, :object_root => false
attributes :id, :name
node(:location) { |p| p.location_string }
node(:commune_name) { |p| p.commune.name }
node(:district_name) { |p| p.commune.district.name }
node(:voivodeship_name) { |p| p.commune.district.voivodeship.name }