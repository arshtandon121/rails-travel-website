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

ActiveRecord::Schema[7.0].define(version: 2024_07_07_094249) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource"
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "booking_messages", force: :cascade do |t|
    t.bigint "booking_id", null: false
    t.string "message_sid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["booking_id"], name: "index_booking_messages_on_booking_id"
  end

  create_table "bookings", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "phone"
    t.bigint "camp_id", null: false
    t.boolean "camp_confirmation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "payment_confirmation"
    t.bigint "payment_id"
    t.bigint "user_id", null: false
    t.string "razorpay_order_id"
    t.jsonb "booking_details"
    t.index ["camp_id"], name: "index_bookings_on_camp_id"
    t.index ["payment_id"], name: "index_bookings_on_payment_id"
    t.index ["user_id"], name: "index_bookings_on_user_id"
  end

  create_table "camps", force: :cascade do |t|
    t.string "name"
    t.decimal "price", precision: 10, scale: 2
    t.integer "person"
    t.json "details"
    t.boolean "available"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "camp_pic", default: [], array: true
    t.integer "category"
    t.integer "user_id"
  end

  create_table "payments", force: :cascade do |t|
    t.string "user_name"
    t.string "user_email"
    t.string "user_phone"
    t.decimal "amount", precision: 10, scale: 2
    t.integer "status", default: 0
    t.bigint "camp_id"
    t.bigint "booking_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "payment_details"
    t.index ["booking_id"], name: "index_payments_on_booking_id"
    t.index ["camp_id"], name: "index_payments_on_camp_id"
    t.index ["user_id"], name: "index_payments_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "phone"
    t.boolean "guest", default: false
    t.integer "role", default: 0
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "booking_messages", "bookings"
  add_foreign_key "bookings", "camps"
  add_foreign_key "bookings", "payments"
  add_foreign_key "bookings", "users"
  add_foreign_key "payments", "bookings"
  add_foreign_key "payments", "camps"
  add_foreign_key "payments", "users"
end
