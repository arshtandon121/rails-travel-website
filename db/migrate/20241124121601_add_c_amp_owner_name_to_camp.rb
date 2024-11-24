class AddCAmpOwnerNameToCamp < ActiveRecord::Migration[7.0]
  def change
    add_column :camps, :camp_name_owner, :string
  end
end
