# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130517145441) do

  create_table "active_admin_comments", :force => true do |t|
    t.string   "resource_id",   :null => false
    t.string   "resource_type", :null => false
    t.integer  "author_id"
    t.string   "author_type"
    t.text     "body"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "namespace"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], :name => "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], :name => "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], :name => "index_admin_notes_on_resource_type_and_resource_id"

  create_table "alerts", :force => true do |t|
    t.integer  "relic_id"
    t.integer  "user_id"
    t.text     "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "file"
    t.string   "state"
    t.string   "author"
    t.string   "date_taken"
  end

  create_table "autocomplitions", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.datetime "indexed_at"
    t.integer  "count",      :default => 0
  end

  create_table "categories", :force => true do |t|
    t.string   "name_key"
    t.integer  "position"
    t.string   "column"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "ancestry"
  end

  add_index "categories", ["ancestry"], :name => "categories_ancestry_trgm_idx"
  add_index "categories", ["ancestry"], :name => "index_categories_on_ancestry"

  create_table "communes", :force => true do |t|
    t.integer  "district_id"
    t.string   "name"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "nr"
    t.integer  "kind"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "viewport"
    t.string   "virtual_id"
  end

  create_table "districts", :force => true do |t|
    t.integer  "voivodeship_id"
    t.string   "name"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.string   "nr"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "viewport"
  end

  create_table "documents", :force => true do |t|
    t.integer  "relic_id"
    t.integer  "user_id"
    t.string   "name"
    t.integer  "size"
    t.string   "mime"
    t.string   "file"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "description"
  end

  create_table "entries", :force => true do |t|
    t.integer  "relic_id"
    t.integer  "user_id"
    t.string   "title"
    t.text     "body"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "events", :force => true do |t|
    t.integer  "relic_id"
    t.integer  "user_id"
    t.string   "name"
    t.string   "date"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "position"
    t.integer  "date_start"
    t.integer  "date_end"
    t.integer  "photo_id"
  end

  create_table "links", :force => true do |t|
    t.integer  "relic_id"
    t.integer  "user_id"
    t.string   "name"
    t.string   "url"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "position"
    t.string   "kind"
    t.string   "category"
    t.string   "formal_name"
  end

  create_table "original_relics", :force => true do |t|
    t.integer  "place_id"
    t.text     "identification"
    t.string   "dating_of_obj"
    t.string   "street"
    t.text     "register_number"
    t.string   "nid_id"
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.string   "ancestry"
    t.integer  "commune_id"
    t.integer  "district_id"
    t.integer  "voivodeship_id"
    t.string   "kind"
    t.text     "description",     :default => ""
    t.integer  "relic_id"
  end

  add_index "original_relics", ["ancestry"], :name => "index_original_relics_on_ancestry"
  add_index "original_relics", ["ancestry"], :name => "original_relics_ancestry_trgm_idx"
  add_index "original_relics", ["commune_id"], :name => "index_original_relics_on_commune_id"
  add_index "original_relics", ["district_id"], :name => "index_original_relics_on_district_id"
  add_index "original_relics", ["place_id"], :name => "index_original_relics_on_place_id"
  add_index "original_relics", ["voivodeship_id"], :name => "index_original_relics_on_voivodeship_id"

  create_table "page_translations", :force => true do |t|
    t.integer  "page_id"
    t.string   "locale"
    t.string   "title"
    t.text     "body"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "permalink"
  end

  add_index "page_translations", ["locale"], :name => "index_page_translations_on_locale"
  add_index "page_translations", ["page_id"], :name => "index_page_translations_on_page_id"

  create_table "pages", :force => true do |t|
    t.string   "name"
    t.string   "title"
    t.text     "body"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.string   "ancestry"
    t.string   "permalink"
    t.integer  "weight",     :default => 0
  end

  add_index "pages", ["ancestry"], :name => "index_pages_on_ancestry"
  add_index "pages", ["permalink"], :name => "index_pages_on_permalink"

  create_table "photos", :force => true do |t|
    t.integer  "relic_id"
    t.integer  "user_id"
    t.string   "name"
    t.string   "author"
    t.string   "file"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.boolean  "main"
    t.string   "date_taken"
    t.integer  "file_full_width"
    t.integer  "file_full_height"
    t.text     "description"
    t.string   "alternate_text"
  end

  create_table "places", :force => true do |t|
    t.integer  "commune_id"
    t.string   "name"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.string   "sym"
    t.boolean  "from_teryt",         :default => true
    t.boolean  "custom",             :default => false
    t.string   "virtual_commune_id"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "viewport"
  end

  create_table "relics", :force => true do |t|
    t.integer  "place_id"
    t.text     "identification"
    t.string   "dating_of_obj"
    t.string   "street"
    t.text     "register_number"
    t.string   "nid_id"
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
    t.string   "ancestry"
    t.integer  "commune_id"
    t.integer  "district_id"
    t.integer  "voivodeship_id"
    t.string   "kind",            :default => "SA"
    t.boolean  "approved",        :default => false
    t.string   "categories"
    t.text     "description",     :default => ""
    t.string   "tags"
    t.string   "type",            :default => "Relic"
    t.string   "country_code",    :default => "PL"
    t.string   "fprovince"
    t.string   "fplace"
    t.text     "documents_info"
    t.text     "links_info"
    t.integer  "user_id"
    t.boolean  "geocoded"
    t.string   "build_state"
    t.text     "reason"
    t.integer  "date_start"
    t.integer  "date_end"
    t.string   "state",           :default => "unchecked"
    t.string   "existence",       :default => "existed"
    t.string   "common_name",     :default => ""
  end

  add_index "relics", ["ancestry"], :name => "relics_ancestry_trgm_idx"
  add_index "relics", ["existence"], :name => "index_relics_on_existence"
  add_index "relics", ["state"], :name => "index_relics_on_state"
  add_index "relics", ["type"], :name => "index_relics_on_type"
  add_index "relics", ["voivodeship_id", "state"], :name => "index_relics_on_voivodeship_id_and_state"

  create_table "search_terms", :force => true do |t|
    t.string   "keyword"
    t.integer  "count",      :default => 1
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "search_terms", ["keyword"], :name => "index_search_terms_on_keyword"

  create_table "seen_relics", :force => true do |t|
    t.integer  "user_id"
    t.integer  "relic_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "seen_relics", ["relic_id"], :name => "index_seen_relics_on_relic_id"
  add_index "seen_relics", ["user_id", "relic_id"], :name => "index_seen_relics_on_user_id_and_relic_id"
  add_index "seen_relics", ["user_id"], :name => "index_seen_relics_on_user_id"

  create_table "suggested_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "suggestions", :force => true do |t|
    t.integer  "relic_id"
    t.integer  "user_id"
    t.integer  "place_id"
    t.string   "place_id_action",       :default => "skip"
    t.text     "identification"
    t.string   "identification_action", :default => "skip"
    t.string   "street"
    t.string   "street_action",         :default => "skip"
    t.string   "dating_of_obj"
    t.string   "dating_of_obj_action",  :default => "skip"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "coordinates_action",    :default => "skip"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.string   "tags"
    t.string   "tags_action",           :default => "skip"
    t.integer  "ancestry"
    t.boolean  "skipped",               :default => false
    t.string   "ip_address"
  end

  add_index "suggestions", ["ancestry"], :name => "index_suggestions_on_ancestry"
  add_index "suggestions", ["coordinates_action"], :name => "index_suggestions_on_coordinates_action"
  add_index "suggestions", ["dating_of_obj_action"], :name => "index_suggestions_on_dating_of_obj_action"
  add_index "suggestions", ["identification_action"], :name => "index_suggestions_on_identification_action"
  add_index "suggestions", ["place_id_action"], :name => "index_suggestions_on_place_id_action"

  create_table "tags", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "tolk_locales", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tolk_locales", ["name"], :name => "index_tolk_locales_on_name", :unique => true

  create_table "tolk_phrases", :force => true do |t|
    t.text     "key"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tolk_translations", :force => true do |t|
    t.integer  "phrase_id"
    t.integer  "locale_id"
    t.text     "text"
    t.text     "previous_text"
    t.boolean  "primary_updated", :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tolk_translations", ["phrase_id", "locale_id"], :name => "index_tolk_translations_on_phrase_id_and_locale_id", :unique => true

  create_table "user_relics", :force => true do |t|
    t.integer  "user_id"
    t.integer  "relic_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "",     :null => false
    t.string   "encrypted_password",     :default => "",     :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
    t.string   "role",                   :default => "user"
    t.string   "username"
    t.string   "seen_relic_order",       :default => "asc"
    t.string   "api_key"
    t.string   "api_secret"
    t.string   "default_locale"
    t.string   "provider"
    t.string   "uid"
    t.string   "avatar"
    t.string   "language",               :default => "pl"
  end

  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "versions", :force => true do |t|
    t.string   "item_type",      :null => false
    t.integer  "item_id",        :null => false
    t.string   "event",          :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.text     "object_changes"
    t.string   "comment"
    t.string   "source"
  end

  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"

  create_table "voivodeships", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "nr"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "viewport"
  end

  create_table "widgets", :force => true do |t|
    t.integer  "user_id"
    t.integer  "widget_template_id"
    t.string   "uid"
    t.text     "config"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.string   "type"
  end

  create_table "wuoz_agencies", :force => true do |t|
    t.string   "city"
    t.string   "director"
    t.string   "email"
    t.string   "address"
    t.string   "district_names"
    t.string   "wuoz_key"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "wuoz_alerts", :force => true do |t|
    t.integer  "wuoz_agency_id"
    t.integer  "alert_id"
    t.datetime "sent_at"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "wuoz_notifications", :force => true do |t|
    t.integer  "wuoz_agency_id"
    t.text     "subject"
    t.text     "body"
    t.text     "alert_ids"
    t.string   "zip_file"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "wuoz_regions", :force => true do |t|
    t.integer  "wuoz_agency_id"
    t.integer  "district_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

end
