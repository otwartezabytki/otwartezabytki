class WuozAgency < ActiveRecord::Base
  attr_accessible :city, :director, :email, :address, :districts, :wuoz_key

  class << self
    def seed!
      delete_all
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

end
