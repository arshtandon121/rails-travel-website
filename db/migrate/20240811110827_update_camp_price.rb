class UpdateCampPrice < ActiveRecord::Migration[7.0]
  def up
    add_column :camp_prices, :sharing_enabled, :boolean, default: false
    
    # Create temporary columns
    add_column :camp_prices, :double_price_json, :json
    add_column :camp_prices, :triple_price_json, :json
    add_column :camp_prices, :quad_price_json, :json
    add_column :camp_prices, :six_price_json, :json

    # Convert existing data to JSON
    CampPrice.find_each do |camp_price|
      camp_price.update_columns(
        double_price_json: { "price" => camp_price.double_price },
        triple_price_json: { "price" => camp_price.triple_price },
        quad_price_json: { "price" => camp_price.quad_price },
        six_price_json: { "price" => camp_price.six_price }
      )
    end

    # Remove old columns
    remove_column :camp_prices, :double_price
    remove_column :camp_prices, :triple_price
    remove_column :camp_prices, :quad_price
    remove_column :camp_prices, :six_price

    # Rename new columns
    rename_column :camp_prices, :double_price_json, :double_price
    rename_column :camp_prices, :triple_price_json, :triple_price
    rename_column :camp_prices, :quad_price_json, :quad_price
    rename_column :camp_prices, :six_price_json, :six_price
  end

  def down
    change_column :camp_prices, :double_price, :decimal
    change_column :camp_prices, :triple_price, :decimal
    change_column :camp_prices, :quad_price, :decimal
    change_column :camp_prices, :six_price, :decimal
    remove_column :camp_prices, :sharing_enabled
  end
end