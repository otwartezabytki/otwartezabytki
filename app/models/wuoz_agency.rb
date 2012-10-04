class WuozAgency < ActiveRecord::Base
  attr_accessible :city, :director, :email, :address, :districts, :wuoz_key

  class << self
    def seed!
      # truncate
      connection.execute("TRUNCATE #{self.table_name};")
      hash = JSON.parse(File.open("#{Rails.root}/db/json/wuoz-agencies.json").read)
      hash.each do |key, obj|
        obj['agencies'].each do |attrs|
          self.create attrs.merge('wuoz_key' => key)
        end
      end
      true
    end
  end

  def wuoz_name
    I18n.t("wuoz.#{wuoz_key}")
  end

  def find_districts
    districts.split(',').map do |name|
      results = District.where(['name = ?', name.strip])
      Rails.logger.error "Cant find #{id}: #{name}" if results.blank?
      results
    end.compact.flatten
  end

end
