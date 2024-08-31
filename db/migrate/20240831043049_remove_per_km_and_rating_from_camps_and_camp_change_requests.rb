class RemovePerKmAndRatingFromCampsAndCampChangeRequests < ActiveRecord::Migration[7.0]
  def change
    remove_column :camps, :per_km, :integer
    remove_column :camps, :rating, :float

    remove_column :camp_change_requests, :per_km, :integer
    remove_column :camp_change_requests, :rating, :float
  end
end
