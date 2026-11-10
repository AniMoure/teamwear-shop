class CartItemsController < ApplicationController
  before_action :set_cart_item, only: %i[increment decrement destroy]

  def create
    @product = Product.find(params[:product_id])
    @cart = current_cart
    @cart.add_item(@product)
    @notice = "#{@product.name} was added to your cart."

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to root_path, notice: @notice }
    end
  end

  def increment
    @cart_item.increment!(:quantity)
    render_cart
  end

  def decrement
    @cart_item.decrease!
    render_cart
  end

  def destroy
    @cart_item.destroy!
    render_cart
  end

  private

  # Only lines of the visitor's own cart can be found: any other id gives a 404.
  def set_cart_item
    @cart = cart_from_session!
    @cart_item = @cart.cart_items.find(params[:id])
  end

  def render_cart
    respond_to do |format|
      format.turbo_stream { render :update_cart }
      format.html { redirect_to cart_path }
    end
  end
end
