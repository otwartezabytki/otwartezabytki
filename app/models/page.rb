# -*- encoding : utf-8 -*-
class Page < ActiveRecord::Base
  attr_accessible :name, :body, :title, :translations_attributes, as: :admin

  translates :body, :title
  accepts_nested_attributes_for :translations
  validates :name, :presence => true, :uniqueness => true

  class Resolver < ActionView::Resolver
    self.caching = false

    protected
      def find_templates(name, prefix, partial, details)
        ::Page.where(:name => name).map do |record|
          initialize_template(record)
        end
      end

      # Initialize an ActionView::Template object based on the record found.
      def initialize_template(record)
        source = record.body
        identifier = "DbPageTemplate - pages/#{record.name}"
        handler = ActionView::Template.registered_template_handler('erb')
        details = {
          :format => Mime['html'],
          :updated_at => record.updated_at,
          :virtual_path => "pages/#{record.name}"
        }
        ActionView::Template.new(source, identifier, handler, details)
      end
  end

end
