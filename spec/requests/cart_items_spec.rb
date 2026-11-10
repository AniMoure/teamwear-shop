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

  describe "changing a line of the cart" do
    let(:item) { Cart.last.cart_items.find_by(product: jersey) }

    before { post cart_items_path(product_id: jersey.id) }

    it "increases the quantity with PATCH /cart_items/:id/increment" do
      patch increment_cart_item_path(item)

      expect(item.reload.quantity).to eq(2)
      expect(response).to redirect_to(cart_path)
    end

    it "decreases the quantity with PATCH /cart_items/:id/decrement" do
      item.update!(quantity: 3)

      patch decrement_cart_item_path(item)

      expect(item.reload.quantity).to eq(2)
      expect(response).to redirect_to(cart_path)
    end

    it "removes the line when decreasing a quantity of one" do
      patch decrement_cart_item_path(item)

      expect(CartItem.exists?(item.id)).to be(false)
    end

    it "removes the line with DELETE /cart_items/:id" do
      item.update!(quantity: 3)

      delete cart_item_path(item)

      expect(CartItem.exists?(item.id)).to be(false)
      expect(response).to redirect_to(cart_path)
    end

    it "updates the cart and the counter with a Turbo Stream" do
      patch increment_cart_item_path(item), as: :turbo_stream

      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      expect(response.body).to include('<turbo-stream action="replace" target="cart">')
      expect(response.body).to include('<turbo-stream action="replace" target="cart_counter">')
      expect(response.body).to include("Cart (2)")
    end

    it "shows the empty cart after removing the last line" do
      delete cart_item_path(item), as: :turbo_stream

      expect(response.body).to include("Your cart is empty")
      expect(response.body).to include("Cart (0)")
    end

    it "cannot change a line of another visitor's cart" do
      other_item = CartItem.create!(cart: Cart.create!, product: jersey, quantity: 1)

      delete cart_item_path(other_item)

      expect(response).to have_http_status(:not_found)
      expect(CartItem.exists?(other_item.id)).to be(true)
    end
  end

  it "returns 404 when the visitor has no cart yet" do
    other_item = CartItem.create!(cart: Cart.create!, product: jersey, quantity: 1)

    patch increment_cart_item_path(other_item)

    expect(response).to have_http_status(:not_found)
    expect(other_item.reload.quantity).to eq(1)
  end
end
