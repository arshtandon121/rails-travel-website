class AddFieldsToCamps < ActiveRecord::Migration[7.0]
  def change
    add_column :camps, :sharing_fields, :boolean, default: false, null: false
    add_column :camps, :per_person_field, :boolean, default: false, null: false
    add_column :camps, :per_km_field, :boolean, default: false, null: false
  end
end
