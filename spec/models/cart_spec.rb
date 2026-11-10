require "rails_helper"

RSpec.describe Cart, type: :model do
  it "has a total of zero when empty" do
    expect(Cart.create!.total_cents).to eq(0)
  end

  it "adds up price times quantity for each item" do
    cart = Cart.create!
    jersey = Product.create!(name: "Home jersey", price_cents: 4500)
    shorts = Product.create!(name: "Training shorts", price_cents: 2900)
    CartItem.create!(cart: cart, product: jersey, quantity: 2)
    CartItem.create!(cart: cart, product: shorts, quantity: 1)

    expect(cart.total_cents).to eq(11_900)
  end

  describe "#add_item" do
    let(:cart) { Cart.create! }
    let(:jersey) { Product.create!(name: "Home jersey", price_cents: 4500) }

    it "creates a line with quantity 1 for a new product" do
      expect { cart.add_item(jersey) }.to change { cart.cart_items.count }.by(1)

      expect(cart.cart_items.find_by(product: jersey).quantity).to eq(1)
    end

    it "increments the quantity when the product is already in the cart" do
      existing_item = CartItem.create!(cart: cart, product: jersey, quantity: 2)

      expect { cart.add_item(jersey) }.not_to change { cart.cart_items.count }

      expect(existing_item.reload.quantity).to eq(3)
    end

    it "increments the quantity when another request created the line in the meantime" do
      # Simulates a double click: the line does not exist when we look for it,
      # but another request inserts it before we do.
      existing_item = CartItem.create!(cart: cart, product: jersey, quantity: 1)
      lookups = 0
      allow(cart.cart_items).to receive(:find_by).and_wrap_original do |original, *args|
        lookups += 1
        lookups == 1 ? nil : original.call(*args)
      end

      expect { cart.add_item(jersey) }.not_to change { CartItem.count }

      expect(existing_item.reload.quantity).to eq(2)
    end

    it "gives up after one retry when the line still cannot be created" do
      allow(cart.cart_items).to receive(:create!).and_raise(ActiveRecord::RecordNotUnique)

      expect { cart.add_item(jersey) }.to raise_error(ActiveRecord::RecordNotUnique)
      expect(cart.cart_items).to have_received(:create!).twice
    end
  end
end
