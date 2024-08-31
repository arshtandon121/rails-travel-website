class ChangeUserIdNullConstraintInCampChangeRequests < ActiveRecord::Migration[7.0]
  def change
    change_column_null :camp_change_requests, :user_id, true
  end
end
