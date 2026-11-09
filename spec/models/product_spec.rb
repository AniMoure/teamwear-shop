require "rails_helper"

RSpec.describe Product, type: :model do
  it "is valid with a name and a positive price" do
    expect(Product.new(name: "Home jersey", price_cents: 4500)).to be_valid
  end

  it "requires a name" do
    product = Product.new(name: "", price_cents: 4500)

    expect(product).not_to be_valid
    expect(product.errors[:name]).to be_present
  end

  it "requires a positive price" do
    product = Product.new(name: "Home jersey", price_cents: 0)

    expect(product).not_to be_valid
    expect(product.errors[:price_cents]).to be_present
  end
end
