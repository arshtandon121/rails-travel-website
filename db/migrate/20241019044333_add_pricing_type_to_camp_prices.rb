class AddPricingTypeToCampPrices < ActiveRecord::Migration[7.0]
  def change
    add_column :camp_prices, :pricing_type, :integer, default: 0
  end
end
