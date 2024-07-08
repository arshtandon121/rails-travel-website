class AddRazorPayBookingId < ActiveRecord::Migration[7.0]
  def change
    add_column :bookings, :razorpay_order_id, :string
  end
end
