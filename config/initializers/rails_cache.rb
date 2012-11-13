# -*- encoding : utf-8 -*-
# "hack" for uninitialized model names
if Rails.env.development?
  Dir.foreach("#{Rails.root}/app/models") do |model_name|
    if model_name.match(/\.rb$/) && model_name.match(/world|country|voivodeship|district|commune|place/)
      require_dependency model_name
    end
  end
end
