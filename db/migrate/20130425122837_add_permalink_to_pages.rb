class AddPermalinkToPages < ActiveRecord::Migration
  def up
    add_column :pages, :permalink, :string
    add_column :page_translations, :permalink, :string
    add_index :pages, :permalink
    permalinks = {
      'download' => 'pobierz-dane',
      'about'    => 'o-projekcie',
      'contact'  => 'kontakt',
      'help'     => 'pomoc',
      'more'     => 'dowiedz-sie-wiecej',
      'terms'    => 'regulamin',
      'privacy'  => 'prywatnosc'
    }
    Page.all.each do |page|
      page.permalink = if permalinks.include? page.name
        permalinks[page.name]
      else
        page.name.parameterize
      end
      page.save
    end
  end

  def down
    remove_index :pages, :permalink
    remove_column :page_translations, :permalink
    remove_column :pages, :permalink
  end
end
