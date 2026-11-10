require "rails_helper"

RSpec.describe CartItem, type: :model do
  let(:cart) { Cart.create! }
  let(:product) { Product.create!(name: "Home jersey", price_cents: 4500) }

  it "is valid with a cart, a product and a quantity" do
    expect(CartItem.new(cart: cart, product: product, quantity: 2)).to be_valid
  end

  it "requires a quantity greater than zero" do
    expect(CartItem.new(cart: cart, product: product, quantity: 0)).not_to be_valid
  end

  it "requires a whole quantity" do
    expect(CartItem.new(cart: cart, product: product, quantity: 1.5)).not_to be_valid
  end

  it "cannot hold the same product twice in a cart" do
    CartItem.create!(cart: cart, product: product, quantity: 1)
    expect(CartItem.new(cart: cart, product: product, quantity: 1)).not_to be_valid
  end

  it "is also protected against duplicates by the database" do
    CartItem.create!(cart: cart, product: product, quantity: 1)
    duplicate = CartItem.new(cart: cart, product: product, quantity: 1)

    expect { duplicate.save(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
  end

  describe "#decrease!" do
    it "lowers the quantity by one" do
      item = CartItem.create!(cart: cart, product: product, quantity: 2)

      item.decrease!

      expect(item.reload.quantity).to eq(1)
    end

    it "removes the line when the quantity was one" do
      item = CartItem.create!(cart: cart, product: product, quantity: 1)

      expect { item.decrease! }.to change(CartItem, :count).by(-1)
    end
  end

  it "computes its total from the product price and the quantity" do
    item = CartItem.new(cart: cart, product: product, quantity: 3)

    expect(item.total_cents).to eq(13_500)
  end
end
