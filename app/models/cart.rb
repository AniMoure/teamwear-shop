class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  def total_cents
    cart_items.includes(:product).sum { |item| item.product.price_cents * item.quantity }
  end

  def add_item(product)
    retried = false

    begin
      cart_item = cart_items.find_by(product: product)

      if cart_item
        cart_item.increment!(:quantity)
      else
        cart_items.create!(product: product, quantity: 1)
      end
    rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid
      # Another request (e.g. a double click) created the line between our
      # lookup and our insert: look it up again and increment it instead.
      raise if retried

      retried = true
      retry
    end
  end
end
