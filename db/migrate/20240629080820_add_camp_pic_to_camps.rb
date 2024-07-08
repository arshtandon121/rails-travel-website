class AddCampPicToCamps < ActiveRecord::Migration[7.0]
  def change
    add_column :camps, :camp_pic, :text, array: true, default: []
  end
end
