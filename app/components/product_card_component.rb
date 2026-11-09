# frozen_string_literal: true

class ProductCardComponent < ViewComponent::Base
  def initialize(product:)
    @product = product
  end

  def formatted_price
    helpers.number_to_currency(@product.price_cents.to_d / 100, unit: "€", separator: ",", delimiter: " ", format: "%n %u")
  end
end
