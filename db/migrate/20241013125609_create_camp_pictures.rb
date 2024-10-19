class CreateCampPictures < ActiveRecord::Migration[7.0]
  def change
    create_table :camp_pictures do |t|
      t.references :camp, null: false, foreign_key: true

      t.timestamps
    end
  end
end