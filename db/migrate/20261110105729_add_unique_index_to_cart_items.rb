class AddUniqueIndexToCartItems < ActiveRecord::Migration[8.1]
  def change
    add_index :cart_items, [ :cart_id, :product_id ], unique: true
  end
end
