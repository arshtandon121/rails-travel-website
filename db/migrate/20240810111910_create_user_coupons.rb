class CreateUserCoupons < ActiveRecord::Migration[7.0]
  def change
    create_table :user_coupons do |t|
      t.references :user, null: false, foreign_key: true
      t.references :camp, null: false, foreign_key: true
      t.string :code, limit: 12, null: false
      t.boolean :used, default: false
      t.decimal :min_price, precision: 10, scale: 2, null: false
      t.decimal :discount, precision: 5, scale: 2, null: false

      t.timestamps
    end
    add_index :user_coupons, :code, unique: true
  end
end