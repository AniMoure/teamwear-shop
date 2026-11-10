class CartItemsController < ApplicationController
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
end
