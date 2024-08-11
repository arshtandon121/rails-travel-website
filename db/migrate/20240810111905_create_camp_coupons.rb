class CreateCampCoupons < ActiveRecord::Migration[7.0]
  def change
    create_table :camp_coupons do |t|
      t.references :camp, null: false, foreign_key: true
      t.decimal :min_price, precision: 10, scale: 2, null: false
      t.decimal :discount, precision: 5, scale: 2, null: false
      t.boolean :active, default: true

      t.timestamps
    end
  end
end