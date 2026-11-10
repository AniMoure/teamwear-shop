# frozen_string_literal: true

class ProductCardComponent < ViewComponent::Base
  def initialize(product:)
    @product = product
  end

  def formatted_price
    helpers.format_price(@product.price_cents)
  end
end
