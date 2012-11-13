# -*- encoding : utf-8 -*-
class PreparedQuery

  def initialize query
    @query = query
  end

  def build
    return @prepared_query if defined? @prepared_query
    return nil if @query.size < 3
    split = @query.gsub(/\*+/, '').split
    # add asterisk only for last word
    split[-1] = "#{split[-1]}*"
    @prepared_query = split.join(' ')
  end

  def exists?
    build.present?
  end

  def regexp
    build.to_s.gsub('*', '.*')
  end

  def clean
    build.to_s.gsub(/\*+/, '')
  end
end
