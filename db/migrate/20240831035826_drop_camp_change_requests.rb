class DropCampChangeRequests < ActiveRecord::Migration[7.0]
  def change
    drop_table :camp_change_requests do |t|
      t.references :camp, foreign_key: true
      t.references :user, foreign_key: true
      t.integer :status, default: 0, null: false
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      # Add any other columns that were part of this table here
    end
  end
end
