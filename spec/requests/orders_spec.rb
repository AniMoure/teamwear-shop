require "rails_helper"

RSpec.describe "Orders", type: :request do
  let!(:jersey) { Product.create!(name: "Home jersey", price_cents: 4500) }
  let(:valid_params) { { order: { customer_name: "Ana", email: "ana@example.com" } } }

  describe "GET /orders/new" do
    it "redirects to the cart when the cart is empty" do
      get new_order_path

      expect(response).to redirect_to(cart_path)
    end

    it "shows the order summary and the form" do
      post cart_items_path(product_id: jersey.id)

      get new_order_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Home jersey", "45,00 €", "Place order")
    end
  end

  describe "POST /orders" do
    before { post cart_items_path(product_id: jersey.id) }

    it "creates the order, empties the cart and shows the confirmation" do
      expect { post orders_path, params: valid_params }.to change(Order, :count).by(1)

      order = Order.last
      expect(response).to redirect_to(order_path(order))
      follow_redirect!
      expect(response.body).to include("Thank you, Ana", order.number, "45,00 €")
      expect(response.body).to include("Cart (0)")
    end

    it "shows the errors and keeps the cart when the form is invalid" do
      expect { post orders_path, params: { order: { customer_name: "", email: "nope" } } }.not_to change(Order, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Customer name can&#39;t be blank")
      expect(response.body).to include("Cart (1)")
    end

    it "redirects to the cart when the cart was already ordered" do
      post orders_path, params: valid_params

      expect { post orders_path, params: valid_params }.not_to change(Order, :count)
      expect(response).to redirect_to(cart_path)
    end
  end

  describe "GET /orders/:token" do
    it "cannot be opened with the order id" do
      post cart_items_path(product_id: jersey.id)
      post orders_path, params: valid_params

      get "/orders/#{Order.last.id}"

      expect(response).to have_http_status(:not_found)
    end
  end
end
