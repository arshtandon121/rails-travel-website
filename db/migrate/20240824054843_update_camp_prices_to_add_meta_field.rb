class UpdateCampPricesToAddMetaField < ActiveRecord::Migration[7.0]
  def change
    remove_column :camp_prices, :double_price, :json
    remove_column :camp_prices, :triple_price, :json
    remove_column :camp_prices, :quad_price, :json
    remove_column :camp_prices, :six_price, :json

    add_column :camp_prices, :meta, :json, default: {}
  end
end
