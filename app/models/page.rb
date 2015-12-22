# -*- encoding : utf-8 -*-
class Page < ActiveRecord::Base
  attr_accessible :name, :body, :title, :translations_attributes, :parent_id, :permalink, :weight, as: :admin

  translates :body, :title, :permalink
  accepts_nested_attributes_for :translations
  validates :name, :permalink, :presence => true, :uniqueness => true
  validates_presence_of :title

  scope :by_weight, order('weight ASC')

  has_ancestry

  class Translation
    attr_accessible :body, :title, :permalink, as: :admin
  end

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
        source       = record.body || ""
        virtual_path = "pages/#{I18n.locale}_#{record.name}_#{record.permalink}"
        handler      = ActionView::Template.registered_template_handler('erb')
        details      = {
          :format => Mime['html'],
          :updated_at => record.updated_at,
          :virtual_path => virtual_path
        }
        ActionView::Template.new(source, "DbPageTemplate - #{virtual_path}", handler, details)
      end
  end

  def parent_id=(value)
    if value.present?
      self.parent = Page.find(value)
    else
      self.parent = nil
    end
  end

  def self.find_all_by_permalink(permalink)
    found = find_by_permalink(permalink)
    found = includes(:translations).where(:translations => { :permalink => permalink }).first unless found
    if found
      found.translations.reload
      [found]
    else
      []
    end
  end

  def subpages
    self.children.by_weight.delete_if { |page| page.permalink.blank? }
  end

  def has_subpages?
    self.subpages.present?
  end

  after_save { self.touch }

  before_validation do
    self.title = self.name if self.title.blank? and self.new_record?
    self.permalink = if self.permalink.blank? and self.new_record?
      self.name.try(:parameterize)
    else
      self.permalink.parameterize
    end
    self.name = self.name.try(:parameterize).try(:underscore)
  end

  class Translation
    after_initialize do
      if self.new_record? and self.locale == I18n.default_locale
        self.body ||= <<-EOS
<div class='content_more'>
  Treść strony
</div>
EOS
      end
    end
  end
end
