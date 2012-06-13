# -*- encoding : utf-8 -*-
require 'csv'
module Import
  class Relic
    Fields = [ :identification, :group, :number, :materail, :dating_of_obj, :register_number, :street ]
    RowSize = 11

    class << self

      def structurize_relics
        ::Relic.find_each(:conditions => {:number => 0}) do |parent_relic|
          logger.info "searching children (#{parent_relic.id})"
          parent_relic.find_children
        end
      end

      def logger
        @logger ||= Logger.new("#{Rails.root}/log/#{Rails.env}_relics_import.log")
      end

      def find_place row
        Import::AdministrativeDivision.find_or_create *row.first(4)
      end

      def prepare_attributes row
        attributes = {}
        attributes = Hash[Fields.zip(row.slice(4, RowSize-1))]
        attributes[:internal_id] = (Digest::SHA1.new << row.join).to_s
        attributes
      end

      def prepare_source row
        fields = [:voivodeship, :district, :commune, :place] + Fields
        Hash[fields.zip(row)]
      end

      def parse(file_path = nil)
        file_path = "#{Rails.root}/vendor/csvs/all_relics.csv" if file_path.blank?
        stats = {
          :updated => 0,
          :created => 0,
          :failed  => 0
        }
        logger.info "=== Import stated at: #{Time.now} ==="

        CSV.foreach(file_path, :col_sep => "\t") do |row|
          begin
            raise ArgumentError.new("row.size: #{row.size}, but should have #{RowSize} element" ) unless row.size == RowSize

            row = row.map {|e| e.to_s.strip }
            place = find_place(row)

            attributes = prepare_attributes(row).merge(
              :source   => prepare_source(row),
              :place_id => place.id
            )

            relic = ::Relic.find_by_internal_id(attributes[:internal_id])

            if relic.blank?
              relic = place.relics.new
              relic.attributes = attributes
              # new_relic = relic.new_record?
              if relic.save
                # new_relic ? stats[:created] += 1 : stats[:updated] += 1
                stats[:created] += 1
              else
                stats[:failed] += 1
                logger.info "failed: #{relic.attributes.inpsect} | errors: #{relic.errors.full_messages.inspect}\n"
              end
            end
          rescue => ex
            stats[:failed] += 1
            logger.info "Unexpected error: #{ex.message} | row: #{row.inspect}"
          end
        end
        logger.info "=== Finisted at: #{Time.now}\n Stats: updated(#{stats[:updated]}), created(#{stats[:created]}), failed(#{stats[:failed]}) ===\n"
      end
    end
  end
end
