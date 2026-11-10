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
end
