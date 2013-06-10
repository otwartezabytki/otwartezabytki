# -*- encoding : utf-8 -*-
class Version < ActiveRecord::Base
  attr_accessible :source
  scope :relics, where(:item_type => "Relic")
  scope :documents, where(:item_type => "Document")
  scope :photos, where(:item_type => "Photo")
  scope :events, where(:item_type => "Event")
  scope :entries, where(:item_type => "Entry")
  scope :links, where(:item_type => "Link")

  def preview
    @preview ||= self.reify ||
    Version.where("item_type = ? AND id > ?", self.item_type, self.id).first.try(:reify) ||
    Kernel.const_get(self.item_type).where(:id => self.item_id).first
  rescue
    Kernel.const_get(self.item_type).where(:id => self.item_id).first
  end
end

require 'yaml'

module PaperTrail
  module Serializers
    module Yaml
      extend self # makes all instance methods become module methods as well

      def load(string)
        YAML.load string
      end

      def dump(object)
        if object.has_key?('file')
          object['file'] = serialize_file_obj(object['file'])
        end
        YAML.dump object
      end

      private

      def serialize_file_obj(file)
        if file.is_a?(Array)
          file.map { |a| get_filename(a) }
        else
          get_filename(file)
        end
      end

      def get_filename(file)
        if file.is_a?(PhotoUploader) or file.is_a?(DocumentUploader)
          File.basename(file.to_s)
        else
          file
        end
      end
    end
  end
end

