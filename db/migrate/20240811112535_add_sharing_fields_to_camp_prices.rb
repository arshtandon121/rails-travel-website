class AddSharingFieldsToCampPrices < ActiveRecord::Migration[7.0]
  def change
    add_column :camp_prices, :double_sharing_enabled, :boolean, default: false
    add_column :camp_prices, :triple_sharing_enabled, :boolean, default: false
    add_column :camp_prices, :quad_sharing_enabled, :boolean, default: false
    add_column :camp_prices, :six_sharing_enabled, :boolean, default: false
  end
end