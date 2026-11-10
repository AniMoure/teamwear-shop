# A line of an order. The product name and price are copied when the order is
# placed, so later changes to the product do not change what was ordered.
class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product, optional: true

  validates :product_name, presence: true
  validates :unit_price_cents, numericality: { only_integer: true, greater_than: 0 }
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }

  def total_cents
    unit_price_cents * quantity
  end
end
