class AddStatusToPayments < ActiveRecord::Migration[7.0]
  def change
    change_column :payments, :status, :integer, using: 'CASE WHEN status = \'pending\' THEN 0 WHEN status = \'completed\' THEN 1 ELSE 2 END', default: 0
  end
end
