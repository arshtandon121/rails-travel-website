class CreateMargins < ActiveRecord::Migration[7.0]
  def change
    create_table :margins do |t|
      t.decimal :margin, precision: 10, scale: 2
      t.references :camp, foreign_key: true, index: { unique: true }

      t.timestamps
    end
  end
end
