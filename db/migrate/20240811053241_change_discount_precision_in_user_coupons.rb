class ChangeDiscountPrecisionInUserCoupons < ActiveRecord::Migration[7.0]
  def change
    change_column :user_coupons, :discount, :decimal, precision: 8, scale: 2
  end
end
