class CreateOrderItems < ActiveRecord::Migration[8.1]
  def change
    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      # Kept for reporting, but the line does not depend on the product:
      # if the product is deleted, the line keeps its name and price.
      t.references :product, null: true, foreign_key: { on_delete: :nullify }
      t.string :product_name, null: false
      t.integer :unit_price_cents, null: false
      t.integer :quantity, null: false
      t.timestamps
    end
  end
end
