class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :product_id, uniqueness: { scope: :cart_id }

  # Lowers the quantity by one, or removes the line when it would reach zero.
  def decrease!
    quantity > 1 ? decrement!(:quantity) : destroy!
  end

  def total_cents
    product.price_cents * quantity
  end
end
