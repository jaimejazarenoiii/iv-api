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

ActiveRecord::Schema[8.0].define(version: 2024_10_11_000008) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "items", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "storage_id", null: false
    t.string "name", limit: 100, null: false
    t.decimal "quantity", precision: 10, scale: 2
    t.string "unit", null: false
    t.decimal "min_quantity", precision: 10, scale: 2
    t.date "expiration_date"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["storage_id", "name"], name: "index_items_on_storage_id_and_name"
    t.index ["storage_id"], name: "index_items_on_storage_id"
    t.index ["user_id", "name"], name: "index_items_on_user_id_and_name"
    t.index ["user_id"], name: "index_items_on_user_id"
  end

  create_table "jwt_denylists", force: :cascade do |t|
    t.string "jti"
    t.datetime "exp"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["jti"], name: "index_jwt_denylists_on_jti"
  end

  create_table "purchase_items", force: :cascade do |t|
    t.bigint "purchase_session_id", null: false
    t.bigint "item_id", null: false
    t.decimal "quantity", precision: 10, scale: 2, null: false
    t.decimal "unit_price", precision: 10, scale: 2, null: false
    t.decimal "total_price", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_purchase_items_on_item_id"
    t.index ["purchase_session_id", "item_id"], name: "index_purchase_items_on_purchase_session_id_and_item_id", unique: true
    t.index ["purchase_session_id"], name: "index_purchase_items_on_purchase_session_id"
  end

  create_table "purchase_sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "store_name", null: false
    t.decimal "total_amount", precision: 10, scale: 2
    t.datetime "purchased_at", null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "purchased_at"], name: "index_purchase_sessions_on_user_id_and_purchased_at"
    t.index ["user_id"], name: "index_purchase_sessions_on_user_id"
  end

  create_table "storages", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "parent_id"
    t.string "name", limit: 100, null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id"], name: "index_storages_on_parent_id"
    t.index ["user_id", "name"], name: "index_storages_on_user_id_and_name"
    t.index ["user_id"], name: "index_storages_on_user_id"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "plan", default: "free", null: false
    t.integer "pantry_limit"
    t.datetime "started_at"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_subscriptions_on_user_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "items", "storages"
  add_foreign_key "items", "users"
  add_foreign_key "purchase_items", "items"
  add_foreign_key "purchase_items", "purchase_sessions"
  add_foreign_key "purchase_sessions", "users"
  add_foreign_key "storages", "storages", column: "parent_id"
  add_foreign_key "storages", "users"
  add_foreign_key "subscriptions", "users"
end
