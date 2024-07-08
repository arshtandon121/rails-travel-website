class AddPaymentDetailsToBookings < ActiveRecord::Migration[7.0]
  def change
    add_column :bookings, :payment_confirmation, :boolean
    add_reference :bookings, :payment, foreign_key: true
  end
end
