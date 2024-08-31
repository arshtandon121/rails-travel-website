class AddDetailsColumnsToCamps < ActiveRecord::Migration[7.0]
  def change
    add_column :camps, :description, :text
    add_column :camps, :per_km, :integer
    add_column :camps, :camp_duration, :string
    add_column :camps, :location, :string
    add_column :camps, :rating, :float
    add_column :camps, :feature, :text, array: true, default: []
  end
end
