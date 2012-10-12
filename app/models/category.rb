# -*- encoding : utf-8 -*-
class Category < ActiveRecord::Base
  attr_accessible :group_key, :name_key, :position, :column
  acts_as_list

  scope :sacral, where(:group_key => 'sakralny')
  scope :non_sacral, where("group_key IS NULL")


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
  end

  def name
    I18n.t("category.names.#{name_key}")
  end

  def group_name
    return if group_key.blank?
    I18n.t("category.groups.#{group_key}")
  end
end
