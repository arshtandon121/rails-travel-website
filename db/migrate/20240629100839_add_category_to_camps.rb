class AddCategoryToCamps < ActiveRecord::Migration[7.0]
  def change
    add_column :camps, :category, :integer
  end
end
