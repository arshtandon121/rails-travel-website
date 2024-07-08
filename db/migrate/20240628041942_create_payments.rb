class CreatePayments < ActiveRecord::Migration[7.0]
  def change
    create_table :payments do |t|
      t.string :user_name
      t.string :user_email
      t.string :user_phone
      t.decimal :amount, precision: 10, scale: 2
      t.string :status
      t.references :camp, foreign_key: true
      t.references :booking, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
