class CreateCamps < ActiveRecord::Migration[7.0]
  def change
    create_table :camps do |t|
      t.string :name
      t.decimal :price, precision: 10, scale: 2
      t.integer :person
      t.json :details
      t.boolean :available

      t.timestamps
    end
  end
end
