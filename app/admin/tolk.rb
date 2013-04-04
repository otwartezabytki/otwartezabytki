# -*- encoding : utf-8 -*-

ActiveAdmin.register_page "Tolk" do
  menu :label => 'Tłumaczenia', :url => '/admin/tolk'
end

Tolk.config do |config|
  config.mapping["by"] = 'Belarus'
  config.mapping["se"] = 'Spanish'
  config.mapping["ua"] = 'Ukrainian'
end