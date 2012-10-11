# -*- encoding : utf-8 -*-
class Page < ActiveRecord::Base
  translates :body, :title
  accepts_nested_attributes_for :translations
end
