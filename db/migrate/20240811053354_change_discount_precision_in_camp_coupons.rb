class ChangeDiscountPrecisionInCampCoupons < ActiveRecord::Migration[7.0]
  def change
    change_column :camp_coupons, :discount, :decimal, precision: 8, scale: 2
  end
end
