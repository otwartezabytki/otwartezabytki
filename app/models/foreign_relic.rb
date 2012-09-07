# == Schema Information
#
# Table name: relics
#
#  id              :integer          not null, primary key
#  place_id        :integer
#  identification  :text
#  group           :string(255)
#  number          :integer
#  materail        :string(255)
#  dating_of_obj   :string(255)
#  street          :string(255)
#  register_number :text
#  nid_id          :string(255)
#  latitude        :float
#  longitude       :float
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  internal_id     :string(255)
#  ancestry        :string(255)
#  source          :text
#  commune_id      :integer
#  district_id     :integer
#  voivodeship_id  :integer
#  register_date   :date
#  date_norm       :string(255)
#  kind            :string(255)
#  approved        :boolean          default(FALSE)
#  categories      :string(255)
#  skip_count      :integer          default(0)
#  edit_count      :integer          default(0)
#  description     :text
#  tags            :string(255)
#  type            :string(255)      default("Relic")
#  country_code    :string(255)      default("PL")
#  fprovince       :string(255)
#  fplace          :string(255)
#  documents_info  :text
#  links_info      :text
#  user_id         :integer
#  geocoded        :boolean
#  build_state     :string(255)
#  reason          :text
#  date_start      :integer
#  date_end        :integer
#

class ForeignRelic < Relic
  def self.model_name
    Relic.model_name
  end

  def to_indexed_hash
    dp = DateParser.new dating_of_obj
    dating_hash = Hash[[:from, :to, :has_round_date].zip(dp.results << dp.rounded?)]
    {
      :id                   => id,
      :type                 => 'relic',
      :identification       => identification,
      :street               => street,
      :street_normalized    => street_normalized,
      :place_full_name      => place_full_name,
      :place_with_address   => place_with_address,
      :descendants          => self.descendants.map(&:to_descendant_hash),
      :fprovince            => fprovince,
      :fplace               => fplace,
      # new fields
      :description          => description,
      :has_description      => description?,
      :categories           => categories,
      :has_photos           => has_photos?,
      :state                => state,
      :existence            => existence,
      :country              => country_code.downcase,
      :tags                 => tags,
      # Lat Lon As Array Format in [lon, lat]
      :coordinates          => [longitude, latitude]
    }.merge(dating_hash)
  end

  def place_full_name(include_place = true)
    [fprovince, fplace].compact.join(', ')
  end

end
