# -*- encoding : utf-8 -*-
class Page < ActiveRecord::Base
  attr_accessible :name, :body, :title, :translations_attributes, :parent_id, :permalink

  translates :body, :title, :permalink
  accepts_nested_attributes_for :translations
  validates :name, :permalink, :presence => true, :uniqueness => true
  validates_presence_of :title

  has_ancestry

  class Resolver < ActionView::Resolver
    self.caching = false

    protected
      def find_templates(name, prefix, partial, details)
        (::Page.find_all_by_permalink(name).presence || ::Page.where(:name => name)).map do |record|
          initialize_template(record)
        end
      end

      # Initialize an ActionView::Template object based on the record found.
      def initialize_template(record)
        source = record.body
        identifier = "DbPageTemplate - pages/#{I18n.locale}_#{record.name}"
        handler = ActionView::Template.registered_template_handler('erb')
        details = {
          :format => Mime['html'],
          :updated_at => record.updated_at,
          :virtual_path => "pages/#{I18n.locale}_#{record.name}"
        }
        ActionView::Template.new(source, identifier, handler, details)
      end
  end

  def parent_id=(value)
    if value.present?
      self.parent = Page.find(value)
    else
      self.parent = nil
    end
  end

  after_save { self.touch }

  before_validation do
    self.title = self.name if self.title.blank? and self.new_record?
    self.permalink = if self.permalink.blank? and self.new_record?
      self.name.parameterize
    else
      self.permalink.parameterize
    end
    self.name = self.name.parameterize.underscore
  end
end
