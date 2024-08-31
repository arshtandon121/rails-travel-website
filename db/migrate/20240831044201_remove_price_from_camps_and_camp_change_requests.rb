class RemovePriceFromCampsAndCampChangeRequests < ActiveRecord::Migration[7.0]
  def change
    remove_column :camps, :price, :decimal     
 
    remove_column :camp_change_requests,  :price, :decimal  

  end
end
