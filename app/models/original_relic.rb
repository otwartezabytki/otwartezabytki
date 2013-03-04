class OriginalRelic < ActiveRecord::Base
  self.primary_key = "id"
  has_ancestry

  belongs_to :relic
  belongs_to :user
  belongs_to :place

  scope :created,  lambda { scoped }

  include Relic::PlaceCaching
  attr_reader :common_name, :documents_info, :links_info

  def existence;        'existed'   end
  def build_finished?;  true        end
  def common_name;      nil         end
  def state;            'unchecked' end
  def polish_relic;     true        end
  def has_photos?;      false       end
  def main_photo;       nil         end
  def to_param;          0           end

  [:entries, :all_links, :categories, :tags, :photos, :alerts, :all_events, :all_documents].each do |attr|
    define_method attr do
      []
    end
  end

  def is_group?
    'ZE' == kind or (is_root? and has_children?)
  end
end
