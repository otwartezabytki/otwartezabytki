# -*- encoding : utf-8 -*-
class Category < ActiveRecord::Base
  attr_accessible :parent, :name_key, :position, :column
  has_ancestry
  acts_as_list

  # scope :sacral, where(:group_key => 'sakralny')
  # scope :non_sacral, where("group_key IS NULL")


  class << self
    ['first', 'second', 'third'].each do |name|
      define_method "#{name}_column" do
        Category.where(:column => name).to_hash
      end
    end
    def to_hash
      scoped.all.inject({}) do |memo, category|
        memo[category.name_key] = category.name
        memo
      end
    end
    def sacral
      children_of(self.find_by_name_key('sakralny'))
    end
  end

  def name
    I18n.t("category.names.#{name_key}")
  end
end
