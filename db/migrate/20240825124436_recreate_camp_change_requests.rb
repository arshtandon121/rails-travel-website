class RecreateCampChangeRequests < ActiveRecord::Migration[7.0]
  def change
    # Drop the existing camp_change_requests table if it exists
    drop_table :camp_change_requests, if_exists: true

    # Create the new camp_change_requests table with the required structure
    create_table :camp_change_requests do |t|
      t.string "name"
      t.decimal "price", precision: 10, scale: 2
      t.integer "person"
      t.json "details"
      t.boolean "available"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.text "camp_pic", default: [], array: true
      t.integer "category"
      t.bigint "user_id", null: false
      t.bigint "camp_id", null: false
      t.integer "status", default: 0

      # Indexes
      t.index ["camp_id"], name: "index_camp_change_requests_on_camp_id"
      t.index ["user_id"], name: "index_camp_change_requests_on_user_id"
    end
  end
end
