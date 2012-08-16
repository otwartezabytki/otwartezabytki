# -*- encoding : utf-8 -*-
class Autocomplition < ActiveRecord::Base
  include Tire::Model::Search
  include Tire::Model::Callbacks

  # create different index for testing
  index_name("#{Rails.env}-autocomplitions")
  settings :number_of_shards => 5, :number_of_replicas => 1,
    :analysis => {
      :filter => {
        :pl_stop => {
          :type           => "stop",
          :ignore_case    => true,
          :stopwords_path => "#{Rails.root}/config/elasticsearch/stopwords.txt"
        },
        :pl_synonym => {
          :type           => "synonym",
          :ignore_case    => true,
          :expand         => false,
          :synonyms_path  => "#{Rails.root}/config/elasticsearch/synonyms.txt"
        }
      },
      :analyzer => {
        :default => {
          :type      => "custom",
          :tokenizer => "standard",
          :filter    => "standard, lowercase, pl_synonym, pl_stop, morfologik_stem, unique"
        }
      }
    }

  class << self
    def gen_stat_file
      CSV.open("#{Rails.root}/tmp/file_stat.csv", 'w') do |csv|
        # csv << ['count', 'identification']
        Relic.group(:identification).count.map do |key, count|
          new_key = key.dup
          new_key.gsub!(/I{0,3}[VX]+I{0,3}/, '')
          new_key.gsub!(/I{1,3}/, '')
          new_key.gsub!(/nr\.?\s*\d+/, '')
          new_key.gsub!(/d\./i , '')
          new_key.gsub!(/\(.*?\)/, '')
          new_key.gsub!(/ob\.?.*$/, '')
          new_key.gsub!(/tzw\.?.*$/, '')
          new_key.gsub!(/p\.?w.*$/, '')
          new_key.gsub!(/[\W\d]+$/i, '')
          new_key.gsub!(/\d+[a-z]?([i,\/\s]+)?\d+[a-z]$/i, '')
          new_key.gsub!(/([i,\/\s]+)?\d+[a-z]$/i, '')
          new_key.gsub!(/[\s,]*$/, '')
          new_key.gsub!(/\s{2,}/, ' ')
          new_key.strip!
          split = new_key.split
          split.pop if split.present? and split.last.size < 2
          split.shift if split.present? and split.first.size < 2
          new_key = split.join(' ')

          { 'key' => new_key, 'count' => count} if new_key.present?
        end.compact.group_by { |i| i['key'] }.sort_by{|k, g| k}.map do |key, group|
          count = group.inject(0) { |s, e| s += e['count']; s }
          csv << [count, key]
        end
      end
    end

    def reindex
      index.delete
      gen_stat_file
      delete_all
      index.create :mappings => tire.mapping_to_hash, :settings => tire.settings
      CSV.foreach("#{Rails.root}/tmp/file_stat.csv") do |row|
        create Hash[[:count, :identification].zip(row)]
      end
      index.refresh
    end

    def search q = nil
      q = q.to_s.strip
      return nil if q.size < 3
      split = q.split
      # add asterisk only for last word
      split[-1] = "#{split[-1]}*"
      prepared_q = split.join(' ')
      tire.search(:load => false, :page => 1, :per_page => 5) do
        query { string prepared_q, :default_operator => 'AND' }
        filter :range, :count => {:gt => 1}
        sort do
          by '_script', {
            'script' =>  '_source.count * doc.score',
            'type' => 'number',
            'order' => 'desc'
          }
        end
      end
    end

    def spellcheck sentence
      speller = FFI::Aspell::Speller.new('pl')
      speller.set("ignore-case", "true")
      speller.suggestion_mode = 'fast'
      sentence.split.map do |word|
        word.size > 3 ? speller.suggestions(word).first.try(:downcase) : word
      end.compact.join(' ')
    end

  end

end
