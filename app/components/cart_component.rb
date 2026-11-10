# frozen_string_literal: true

class CartComponent < ViewComponent::Base
  def initialize(cart:)
    @cart = cart
  end

  def items
    @items ||= @cart.cart_items.includes(:product).order(:id)
  end

  def price(cents)
    helpers.format_price(cents)
  end
end
