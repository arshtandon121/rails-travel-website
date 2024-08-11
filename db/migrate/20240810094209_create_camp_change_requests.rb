class CreateCampChangeRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :camp_change_requests do |t|
      t.references :camp, null: false, foreign_key: true
      t.string :name
      t.decimal :price
      t.integer :person
      t.boolean :available
      t.string :category
      t.text :details
      t.references :user, null: false, foreign_key: true
      t.integer :status, default: 0

      # Add Camp::META fields here
      Camp::META.each do |meta_field|
        t.string meta_field
      end

      t.timestamps
    end
  end
end