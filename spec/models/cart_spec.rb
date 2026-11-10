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
end
