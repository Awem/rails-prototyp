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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20151125150323) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "budgets", force: :cascade do |t|
    t.text     "name"
    t.text     "description"
    t.decimal  "amount"
    t.boolean  "effective"
    t.datetime "expires"
    t.integer  "matcher_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "contributions", force: :cascade do |t|
    t.integer  "project_id"
    t.integer  "matcher_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.decimal  "amount",     precision: 30, scale: 2
    t.integer  "invoice_id"
    t.text     "title"
    t.integer  "budget_id"
  end

  add_index "contributions", ["matcher_id"], name: "index_contributions_on_matcher_id", using: :btree
  add_index "contributions", ["project_id"], name: "index_contributions_on_project_id", using: :btree

  create_table "groups", force: :cascade do |t|
    t.text     "name"
    t.text     "description"
    t.text     "category"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "logo",        default: 0
  end

  create_table "invoices", force: :cascade do |t|
    t.text     "number"
    t.text     "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "matcher_id"
  end

  create_table "matchers", force: :cascade do |t|
    t.text     "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "featured"
    t.integer  "logo",        default: 0
  end

  create_table "memberships", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "group_id"
    t.text     "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "partnerships", force: :cascade do |t|
    t.integer  "project_id"
    t.integer  "matcher_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "factor",     precision: 4, scale: 2
  end

  add_index "partnerships", ["matcher_id"], name: "index_partnerships_on_matcher_id", using: :btree
  add_index "partnerships", ["project_id", "matcher_id"], name: "index_partnerships_on_project_id_and_matcher_id", unique: true, using: :btree
  add_index "partnerships", ["project_id"], name: "index_partnerships_on_project_id", using: :btree

  create_table "payments", force: :cascade do |t|
    t.text     "provider"
    t.jsonb    "payload"
    t.jsonb    "response"
    t.text     "matched"
    t.text     "status"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "contribution_id"
  end

  create_table "pictures", force: :cascade do |t|
    t.text     "name"
    t.text     "url"
    t.integer  "theme_id"
    t.string   "theme_type"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.text     "original_filename"
    t.integer  "file_size"
    t.text     "picture_asset"
    t.text     "uuid_secure_token"
    t.text     "content_type"
  end

  add_index "pictures", ["theme_id"], name: "index_pictures_on_theme_id", using: :btree
  add_index "pictures", ["theme_type", "theme_id"], name: "index_pictures_on_theme_type_and_theme_id", using: :btree

  create_table "projects", force: :cascade do |t|
    t.text     "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "paypal_account"
    t.text     "featured"
    t.integer  "logo",           default: 0
  end

  create_table "trips", force: :cascade do |t|
    t.text     "origin"
    t.text     "destination"
    t.decimal  "origin_lat",      precision: 10, scale: 6
    t.decimal  "origin_lng",      precision: 10, scale: 6
    t.decimal  "destination_lat", precision: 10, scale: 6
    t.decimal  "destination_lng", precision: 10, scale: 6
    t.decimal  "length",          precision: 10, scale: 3
    t.decimal  "multiplier",      precision: 10, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "contribution_id"
  end

  create_table "users", force: :cascade do |t|
    t.text     "name"
    t.text     "email",                   default: "",     null: false
    t.boolean  "admin",                   default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "fam_name"
    t.text     "encrypted_password",      default: "",     null: false
    t.text     "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",           default: 0,      null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.text     "current_sign_in_ip"
    t.text     "last_sign_in_ip"
    t.string   "authentication_token"
    t.text     "contribution_visibility", default: "full"
    t.integer  "profile_picture",         default: 0
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "watchword_id"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "watchwords", force: :cascade do |t|
    t.text     "token"
    t.text     "description"
    t.boolean  "effective",   default: true
    t.date     "expires"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

end
