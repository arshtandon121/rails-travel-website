class AddMetaDataToPayments < ActiveRecord::Migration[7.0]
  def change
    add_column :payments, :payment_details, :jsonb
  end
end
