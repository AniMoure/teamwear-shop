class OrdersController < ApplicationController
  def new
    @cart = find_cart_from_session
    return redirect_to(cart_path, alert: Order::EMPTY_CART) if @cart.nil? || @cart.cart_items.none?

    @order = Order.new
  end

  def create
    @cart = find_cart_from_session
    @order = Order.place(cart: @cart, customer_name: order_params[:customer_name], email: order_params[:email])

    if @order.persisted?
      session.delete(:cart_id)
      redirect_to @order
    elsif @order.errors.added?(:base, Order::EMPTY_CART)
      redirect_to cart_path, alert: Order::EMPTY_CART
    else
      render :new, status: :unprocessable_content
    end
  end

  def show
    @order = Order.find_by!(token: params[:id])
  end

  private

  def order_params
    params.expect(order: [ :customer_name, :email ])
  end
end
