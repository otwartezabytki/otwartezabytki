# -*- encoding : utf-8 -*-
class DateParser

  class << self
    def round_range from, to
      [ (from.to_i - 1) / 25 * 25 + 1, (to.to_i / 25.0).ceil * 25 + 1 ]
    end
  end

  def initialize string = nil
    @string = string.to_s
  end

  def split!
    @s, @e = @string.split(/\-|do/).map &:strip
  end

  def results
    split!
    results = [get_arabic_date(@s), get_arabic_date(@e)].flatten.compact
    a_start, a_end = results.first.to_s, results.last.to_s
    a_end = a_start.first(2) + a_end if a_end.size == 2
    [ (a_start.blank? ? nil : a_start.to_i), (a_end.blank? ? nil : a_end.to_i) ]
  end

  def rounded?
    split!
    ![@s, @e].find_all(&:present?).all? { |s| s.match(/^.*?(\d+)$/) }
  end

  def parse_century roman
    # return arabic date of century beginning
    ((Arrabiata.to_arabic(roman) - 1) * 100) + 1
  end

  def get_arabic_date s
    return nil if s.blank?
    if s.match /^.*?(\d+)/
      # przed 1986, 1964
      [$1, $1]
    elsif s.match /(\d).*?[cć]w.*?([IVX]+)/
      # 2 cw XIX
      quarter = ($1 || 1).to_i
      century = parse_century($2)
      a_end = century + (quarter * 25)
      [a_end - 25, a_end]
    elsif s.match /(\d).*?po[lł].*?([IVX]+)/
      # 1 pol XIX
      half = ($1 || 1).to_i
      century = parse_century($2)
      a_end = century + (half * 50)
      [a_end - 50, a_end]
    elsif s.match /kon.*?([IVX]+)/
      # kon. XIX
      century = ((Arrabiata.to_arabic($1)) * 100) + 1
      [century - 25, century]
    elsif s.match /pocz.*?([IVX]+)/
      # pocz. XIV
      century = parse_century($1)
      [century, century + 25]
    elsif s.match /.*?([IVX]+)/
      centuries = s.scan(/.*?([IVX]+)/).flatten
      if centuries.size == 1
        a_start = parse_century(centuries.first)
        a_end = a_start + 100
        [a_start, a_end]
      elsif centuries.size > 1
        a_start = parse_century(centuries[0]) + 75
        a_end = parse_century(centuries[1]) + 25
        [a_start, a_end]
      else
        nil
      end
    else
      puts "Can't parse: #{s}"
      nil
    end
  end
end