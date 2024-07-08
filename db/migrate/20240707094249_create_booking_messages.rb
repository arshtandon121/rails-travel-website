class CreateBookingMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :booking_messages do |t|
      t.references :booking, null: false, foreign_key: true
      t.string :message_sid

      t.timestamps
    end
  end
end
