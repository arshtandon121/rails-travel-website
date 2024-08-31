class AddRating < ActiveRecord::Migration[7.0]
  def change
    add_column :camps, :rating, :decimal, precision: 3, scale: 2, default: 0.0
    add_column :camp_change_requests, :rating, :decimal, precision: 3, scale: 2, default: 0.0
  end
end
