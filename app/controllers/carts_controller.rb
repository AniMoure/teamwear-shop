class CartsController < ApplicationController
  def show
    # An unsaved empty cart: visiting the page does not create a cart.
    @cart = find_cart_from_session || Cart.new
  end
end
