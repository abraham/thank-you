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

ActiveRecord::Schema.define(version: 20170307033025) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pgcrypto"

  create_table "deeds", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "text", null: false
    t.string "twitter_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "names", null: false, array: true
    t.uuid "user_id", null: false
    t.integer "thanks_count", default: 0, null: false
    t.json "data"
    t.integer "status", default: 0, null: false
    t.index ["user_id"], name: "index_deeds_on_user_id"
  end

  create_table "links", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "url", null: false
    t.string "text", null: false
    t.uuid "deed_id", null: false
    t.uuid "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deed_id"], name: "index_links_on_deed_id"
    t.index ["user_id"], name: "index_links_on_user_id"
  end

  create_table "subscriptions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id"
    t.string "token", null: false
    t.text "topics", array: true
    t.datetime "active_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "thanks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "text", null: false
    t.uuid "deed_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "data", null: false
    t.uuid "user_id", null: false
    t.string "twitter_id", null: false
    t.index ["deed_id", "user_id"], name: "index_thanks_on_deed_id_and_user_id", unique: true
    t.index ["deed_id"], name: "index_thanks_on_deed_id"
    t.index ["twitter_id"], name: "index_thanks_on_twitter_id", unique: true
    t.index ["user_id"], name: "index_thanks_on_user_id"
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
    t.integer "role", default: 0, null: false
  end

  add_foreign_key "deeds", "users"
  add_foreign_key "links", "deeds"
  add_foreign_key "links", "users"
  add_foreign_key "subscriptions", "users"
  add_foreign_key "thanks", "users"
end
