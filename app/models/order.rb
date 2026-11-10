class Order < ApplicationRecord
  EMPTY_CART = "Your cart is empty.".freeze

  has_many :order_items, dependent: :destroy
  has_secure_token :token

  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :customer_name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :total_cents, numericality: { only_integer: true, greater_than: 0 }

  # Turns the cart into an order and empties the cart, all in one transaction.
  # Returns the order: persisted on success, with errors otherwise.
  def self.place(cart:, customer_name:, email:)
    order = new(customer_name: customer_name, email: email)

    transaction do
      # Locks the cart row. A second submit of the same cart waits here,
      # then finds the cart deleted (RecordNotFound) instead of ordering twice.
      cart&.lock!
      cart_items = cart ? cart.cart_items.includes(:product).to_a : []

      cart_items.each do |item|
        order.order_items.build(
          product: item.product,
          product_name: item.product.name,
          unit_price_cents: item.product.price_cents,
          quantity: item.quantity
        )
      end
      order.total_cents = order.order_items.sum(&:total_cents)

      if cart_items.empty?
        order.errors.add(:base, EMPTY_CART)
      elsif order.save
        cart.destroy!
      end
    end

    order
  rescue ActiveRecord::RecordNotFound
    order.errors.add(:base, EMPTY_CART)
    order
  end

  def number
    format("TW-%06d", id)
  end

  # Order URLs use the random token, so nobody can read an order by guessing its id.
  def to_param
    token
  end
end
