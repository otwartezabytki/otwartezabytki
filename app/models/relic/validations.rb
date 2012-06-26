# this module caches location fields for quick access
module Relic::Validations
  extend ActiveSupport::Concern

  included do
    validates :place_id, :presence => true
  end

end