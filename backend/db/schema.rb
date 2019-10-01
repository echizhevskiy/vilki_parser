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

ActiveRecord::Schema.define(version: 2019_09_30_124113) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "arbitrations", force: :cascade do |t|
    t.integer "event_id"
    t.integer "first_bet_id"
    t.integer "second_bet_id"
    t.integer "third_bet_id"
    t.float "ratio"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "bets", force: :cascade do |t|
    t.integer "event_id", null: false
    t.string "office", null: false
    t.string "kind", null: false
    t.float "ratio"
    t.float "attr_1"
    t.float "attr_2"
    t.string "attr_3"
    t.float "attr_4"
    t.float "attr_5"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "last_update"
  end

  create_table "events", force: :cascade do |t|
    t.string "match_kind"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "home_team"
    t.string "guest_team"
    t.datetime "date"
  end

end
