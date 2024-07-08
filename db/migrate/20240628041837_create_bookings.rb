class CreateBookings < ActiveRecord::Migration[7.0]
  def change
    create_table :bookings do |t|
      t.string :name
      t.string :email
      t.string :phone
      t.references :camp, null: false, foreign_key: true
      t.boolean :camp_confirmation
   

      t.timestamps
    end
  end
end
