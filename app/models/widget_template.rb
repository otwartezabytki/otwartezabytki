class WidgetTemplate < ActiveRecord::Base
  attr_accessible :description, :type, :name, :thumb, :as => :admin

  validates :name, :presence => true

  has_many :widgets

  def partial_name
    self.class.name.underscore
  end

  class << self
    def configuration(*args)
      args.each do |arg|
        self.class_eval <<-EOS
          def #{arg}
            config[:#{arg}]
          end

          def #{arg}=(value)
            config[:#{arg}] = value
          end
        EOS
      end
    end
  end
end
