class AddDetailsToBookings < ActiveRecord::Migration[7.0]
  def change
    add_column :bookings, :booking_details, :jsonb
  end
end
