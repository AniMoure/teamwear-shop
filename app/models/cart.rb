class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  def total_cents
    cart_items.sum { |item| item.product.price_cents * item.quantity }
  end
end
