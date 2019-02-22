class AddBasisDatabase < ActiveRecord::Migration[4.2]
  def change
    create_table "areas", :force => true do |t|
      t.string   "name"
      t.string   "domain"
      t.string   "adsense_ad_slot_header"
      t.string   "adsense_ad_slot_footer"
      t.string   "adsense_ad_slot_show"
      t.datetime "created_at",  :null => false
      t.datetime "updated_at",  :null => false
    end

    add_index "areas", ["id"], :name => "index_areas_on_id"

    create_table "events", :force => true do |t|
      t.integer  "photo_id"
      t.string   "uuid"
      t.string   "eid"
      t.string   "name"
      t.string   "location"
      t.string   "street"
      t.string   "zipcode"
      t.string   "city",                limit: 255
      t.string   "area"
      t.string   "country"
      t.string   "website"
      t.datetime "start_time"
      t.text     "description"
      t.text     "description_html"
      t.string   "facebook_image_url"
      t.datetime "updated_at",   :null => false
      t.datetime "created_at",  :null => false
    end

    add_index "events", ["id"], :name => "index_events_on_id"

    create_table "photos", :force => true do |t|
      t.string   "name"
      t.string   "content_type"
      t.string   "sha1"
      t.string   "md5"
      t.datetime "created_at",   :null => false
      t.datetime "updated_at",   :null => false
    end

    add_index "photos", ["id"], :name => "index_photos_on_id"

    create_table "block_word_descriptions", force: true do |t|
      t.string   "word"
    end
    add_index "block_word_descriptions", ["id"], :name => "index_block_word_descriptions_on_id"

    create_table "block_word_locations", force: true do |t|
      t.string   "word"
    end
    add_index "block_word_locations", ["id"], :name => "index_block_word_locations_on_id"

    create_table "block_word_titles", force: true do |t|
      t.string   "word"
    end
    add_index "block_word_titles", ["id"], :name => "index_block_word_titles_on_id"
  end
end
