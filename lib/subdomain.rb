# -*- encoding : utf-8 -*-
class Subdomain
  def self.matches?(request)
    request.subdomain.present? && request.subdomain != 'www' && request.subdomain.include?('iframe')
  end
end
