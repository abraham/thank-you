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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170211150757) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pgcrypto"

  create_table "deeds", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "text", null: false
    t.string "reply_to_tweet_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "name", null: false, array: true
    t.uuid "user_id", null: false
    t.integer "thanks_count", default: 0, null: false
    t.index ["user_id"], name: "index_deeds_on_user_id", using: :btree
  end

  create_table "links", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "url", null: false
    t.string "text", null: false
    t.uuid "deed_id", null: false
    t.uuid "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deed_id"], name: "index_links_on_deed_id", using: :btree
    t.index ["user_id"], name: "index_links_on_user_id", using: :btree
  end

  create_table "thanks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "text", null: false
    t.uuid "deed_id", null: false
    t.string "tweet_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "data"
    t.uuid "user_id", null: false
    t.index ["deed_id", "user_id"], name: "index_thanks_on_deed_id_and_user_id", unique: true, using: :btree
    t.index ["deed_id"], name: "index_thanks_on_deed_id", using: :btree
    t.index ["user_id"], name: "index_thanks_on_user_id", using: :btree
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "twitter_id", null: false
    t.string "screen_name", null: false
    t.string "name", null: false
    t.string "avatar_url", null: false
    t.json "data", null: false
    t.string "access_token", null: false
    t.string "access_token_secret", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "deeds_count", default: 0, null: false
    t.integer "thanks_count", default: 0, null: false
    t.string "email", null: false
    t.integer "status", default: 0, null: false
    t.boolean "default_avatar", default: true, null: false
  end

  add_foreign_key "deeds", "users"
  add_foreign_key "links", "deeds"
  add_foreign_key "links", "users"
  add_foreign_key "thanks", "users"
end
