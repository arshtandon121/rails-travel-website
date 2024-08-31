class AddDetailsColumnsToCampChangeRequests < ActiveRecord::Migration[7.0]
  def change
    add_column :camp_change_requests, :description, :text
    add_column :camp_change_requests, :per_km, :integer
    add_column :camp_change_requests, :camp_duration, :string
    add_column :camp_change_requests, :location, :string
    add_column :camp_change_requests, :rating, :float
    add_column :camp_change_requests, :feature, :text, array: true, default: []
  end
end
