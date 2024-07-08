class ChangeRoleFromUser < ActiveRecord::Migration[7.0]

    def up
      # First, add a new column
      add_column :users, :role_integer, :integer, default: 0
  
      # Then, update the new column based on the old one
      execute <<-SQL
        UPDATE users
        SET role_integer = CASE
          WHEN role = 'admin' THEN 1
          ELSE 0
        END
      SQL
  
      # Remove the old column
      remove_column :users, :role
  
      # Rename the new column to 'role'
      rename_column :users, :role_integer, :role
    end
  
    def down
      # If you need to roll back, you can convert back to string
      change_column :users, :role, :string
      
      execute <<-SQL
        UPDATE users
        SET role = CASE
          WHEN role = '1' THEN 'admin'
          ELSE 'user'
        END
      SQL
    end
  end