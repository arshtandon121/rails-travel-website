class AddAuthorizedToCamps < ActiveRecord::Migration[7.0]
  def change
    add_column :camps, :authorized, :boolean, default: false
  end
end
