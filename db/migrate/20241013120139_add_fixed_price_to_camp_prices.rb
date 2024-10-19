class AddFixedPriceToCampPrices < ActiveRecord::Migration[7.0]
  def change
    add_column :camp_prices, :fixed_price, :decimal, precision: 10, scale: 2
    add_column :camp_prices, :fixed_price_enabled, :boolean, default: false
  end
end
