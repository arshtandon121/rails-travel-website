class CreateCampChangeRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :camp_change_requests do |t|
      t.string :name
      t.decimal :price
      t.integer :person
      t.boolean :available
      t.integer :category
      t.text :details
      t.text :camp_pic
      t.references :user, null: false, foreign_key: true
      t.references :camp, null: false, foreign_key: true
      t.boolean :admin_approved

      t.timestamps
    end
  end
end
