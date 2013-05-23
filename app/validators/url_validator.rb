class UrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    begin
      uri = URI.parse(value)
      resp = uri.kind_of?(URI::HTTP) || uri.kind_of?(URI::FTP)
    rescue URI::InvalidURIError
      resp = false
    end
    unless resp == true
      record.errors[attribute] << (options[:message] || I18n.t('activemodel.errors.messages.not_a_url'))
    end
  end
end
