class AddPaymentClearedToCampOwnerToPayments < ActiveRecord::Migration[7.0]
  def change
    add_column :payments, :payment_cleared_to_camp, :boolean, default: false
  end
end
