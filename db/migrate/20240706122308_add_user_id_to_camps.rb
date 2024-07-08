class AddUserIdToCamps < ActiveRecord::Migration[7.0]
  def change
    add_column :camps, :user_id, :integer
  end
end
