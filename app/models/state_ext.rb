# -*- encoding : utf-8 -*-

module StateExt
  extend ActiveSupport::Concern

  included do
    scope :state, lambda {|val| where(:state => val.to_s) }

    before_create do
      self.state = 'uploaded'
    end
  end

  [:initialized, :uploaded, :saved].each do |name|
    define_method "#{name}?" do
      self.state == name.to_s
    end
  end
end
