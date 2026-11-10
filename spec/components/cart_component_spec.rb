# frozen_string_literal: true

require "rails_helper"

RSpec.describe CartComponent, type: :component do
  it "shows an empty state with a link to the catalog" do
    html = render_inline(described_class.new(cart: Cart.new))

    expect(html.css("#cart").text).to include("Your cart is empty")
    expect(html.css("#cart a[href='/']")).to be_present
  end

  it "shows one row per line with quantity, line total and buttons" do
    cart = Cart.create!
    jersey = Product.create!(name: "Home jersey", price_cents: 4500)
    item = CartItem.create!(cart: cart, product: jersey, quantity: 2)

    html = render_inline(described_class.new(cart: cart))

    row = html.css("#cart_item_#{item.id}")
    expect(row.text).to include("Home jersey", "45,00 €", "90,00 €")
    expect(row.css("[data-quantity]").text.strip).to eq("2")
    expect(row.css("form[action='/cart_items/#{item.id}/increment'] button").text).to eq("+")
    expect(row.css("form[action='/cart_items/#{item.id}/decrement'] button").text).to eq("−")
    expect(row.css("form[action='/cart_items/#{item.id}'] input[name='_method'][value='delete']")).to be_present
  end

  it "shows the cart total" do
    cart = Cart.create!
    CartItem.create!(cart: cart, product: Product.create!(name: "Home jersey", price_cents: 4500), quantity: 2)
    CartItem.create!(cart: cart, product: Product.create!(name: "Training shorts", price_cents: 2900), quantity: 1)

    html = render_inline(described_class.new(cart: cart))

    expect(html.css("#cart_total").text).to include("119,00 €")
  end

  it "links back to the catalog when the cart has products" do
    cart = Cart.create!
    CartItem.create!(cart: cart, product: Product.create!(name: "Home jersey", price_cents: 4500), quantity: 1)

    html = render_inline(described_class.new(cart: cart))

    expect(html.css("#cart a[href='/']").text).to eq("Browse our catalog")
  end
end
