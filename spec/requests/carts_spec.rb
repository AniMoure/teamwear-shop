require "rails_helper"

RSpec.describe "Cart", type: :request do
  describe "GET /cart" do
    it "says the cart is empty when the visitor has no cart" do
      get cart_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Your cart is empty")
    end

    it "does not create a cart just to show the page" do
      expect { get cart_path }.not_to change(Cart, :count)
    end

    it "lists the products of the visitor's cart with the total" do
      jersey = Product.create!(name: "Home jersey", price_cents: 4500)
      shorts = Product.create!(name: "Training shorts", price_cents: 2900)
      post cart_items_path(product_id: jersey.id)
      post cart_items_path(product_id: jersey.id)
      post cart_items_path(product_id: shorts.id)

      get cart_path

      expect(response.body).to include("Home jersey", "Training shorts")
      expect(response.body).to include("90,00 €") # 2 jerseys
      expect(response.body).to include("119,00 €") # cart total
    end
  end
end
