class OriginalRelic < ActiveRecord::Base
  self.primary_key = "id"
  has_ancestry

  belongs_to :relic
  belongs_to :user
  belongs_to :place

  include Relic::PlaceCaching
  attr_reader :common_name, :documents_info, :links_info

  def id;               0           end
  def existence;        'existed'   end
  def build_finished?;  true        end
  def common_name;      nil         end
  def state;            'unchecked' end
  def polish_relic;     true        end
  def has_photos?;      false       end

  [:entries, :all_links, :categories, :tags, :alerts, :all_events, :all_documents].each do |attr|
    define_method attr do
      []
    end
  end
end