class AddUserIdToAdminUsers < ActiveRecord::Migration[7.0]
  def change
    add_reference :admin_users, :user, foreign_key: true, index: true
  end
end
