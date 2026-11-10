class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.string :customer_name, null: false
      t.string :email, null: false
      t.integer :total_cents, null: false
      t.string :token, null: false
      t.timestamps
    end
    add_index :orders, :token, unique: true
  end
end
