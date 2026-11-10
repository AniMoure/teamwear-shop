require "rails_helper"

RSpec.describe "Cart items", type: :request do
  let!(:jersey) { Product.create!(name: "Home jersey", price_cents: 4500) }

  describe "POST /cart_items" do
    it "creates a cart for the visitor and adds the product to it" do
      expect { post cart_items_path(product_id: jersey.id) }.to change(Cart, :count).by(1)

      expect(Cart.last.cart_items.find_by(product: jersey).quantity).to eq(1)
    end

    it "reuses the same cart on the next requests" do
      post cart_items_path(product_id: jersey.id)

      expect { post cart_items_path(product_id: jersey.id) }.not_to change(Cart, :count)

      expect(Cart.last.cart_items.find_by(product: jersey).quantity).to eq(2)
    end

    it "creates a new cart when the cart in the session no longer exists" do
      post cart_items_path(product_id: jersey.id)
      Cart.destroy_all

      expect { post cart_items_path(product_id: jersey.id) }.to change(Cart, :count).by(1)
    end

    it "updates the cart counter and the flash with a Turbo Stream" do
      post cart_items_path(product_id: jersey.id), as: :turbo_stream

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      expect(response.body).to include('<turbo-stream action="replace" target="cart_counter">')
      expect(response.body).to include('<turbo-stream action="update" target="flash">')
      expect(response.body).to include("Cart (1)")
      expect(response.body).to include("Home jersey was added to your cart.")
    end

    it "redirects to the catalog with a notice without Turbo" do
      post cart_items_path(product_id: jersey.id)

      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(response.body).to include("Home jersey was added to your cart.")
      expect(response.body).to include("Cart (1)")
    end

    it "returns 404 for an unknown product" do
      post cart_items_path(product_id: 0)

      expect(response).to have_http_status(:not_found)
    end
  end
end
