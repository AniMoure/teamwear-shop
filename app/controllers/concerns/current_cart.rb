# The visitor's cart is kept in the database; the session only stores its id.
module CurrentCart
  extend ActiveSupport::Concern

  included do
    helper_method :cart_items_count
  end

  private

  # Finds the visitor's cart, or creates one the first time it is needed.
  def current_cart
    @current_cart ||= find_cart_from_session || Cart.create!.tap { |cart| session[:cart_id] = cart.id }
  end

  # Used by the layout: does not create a cart just to display "Cart (0)".
  def cart_items_count
    find_cart_from_session&.items_count || 0
  end

  def find_cart_from_session
    Cart.find_by(id: session[:cart_id]) if session[:cart_id]
  end
end
