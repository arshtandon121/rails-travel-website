class CreateCampPrices < ActiveRecord::Migration[7.0]
  def change
    create_table :camp_prices do |t|
      t.references :camp, null: false, foreign_key: true
      t.decimal :per_km
      t.decimal :double_price
      t.decimal :triple_price
      t.decimal :quad_price
      t.decimal :six_price
      t.json :week_days, null: false, default: {
        monday: nil,
        tuesday: nil,
        wednesday: nil,
        thursday: nil,
        friday: nil,
        saturday: nil,
        sunday: nil
      }

      t.timestamps
    end
  end
end
