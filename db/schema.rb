# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_04_19_100856) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "beacon_participants", force: :cascade do |t|
    t.bigint "beacon_id", null: false
    t.datetime "created_at", null: false
    t.integer "status"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["beacon_id"], name: "index_beacon_participants_on_beacon_id"
    t.index ["user_id"], name: "index_beacon_participants_on_user_id"
  end

  create_table "beacons", force: :cascade do |t|
    t.integer "beacon_type", null: false
    t.integer "category", null: false
    t.datetime "created_at", null: false
    t.bigint "creator_id", null: false
    t.text "description"
    t.datetime "event_time", null: false
    t.integer "join_policy", null: false
    t.integer "max_participants", null: false
    t.integer "status", default: 0, null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_beacons_on_creator_id"
  end

  create_table "password_resets", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at"
    t.string "token"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["token"], name: "index_password_resets_on_token", unique: true
    t.index ["user_id"], name: "index_password_resets_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "google_uid"
    t.string "name"
    t.string "password_digest"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["google_uid"], name: "index_users_on_google_uid", unique: true
  end

  add_foreign_key "beacon_participants", "beacons"
  add_foreign_key "beacon_participants", "users"
  add_foreign_key "beacons", "users", column: "creator_id"
  add_foreign_key "password_resets", "users"
end
