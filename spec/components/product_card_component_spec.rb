# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProductCardComponent, type: :component do
  it "shows the product name and its price in euros" do
    product = Product.new(name: "Home jersey", price_cents: 4500)

    render_inline(described_class.new(product: product))

    expect(rendered_content).to include("Home jersey")
    expect(rendered_content).to include("45,00 €")
  end

  it "has an Add to cart button that posts the product" do
    product = Product.create!(name: "Home jersey", price_cents: 4500)

    html = render_inline(described_class.new(product: product))

    form = html.css("form[action='/cart_items?product_id=#{product.id}'][method='post']")
    expect(form).to be_present
    expect(form.css("button").text).to eq("Add to cart")
  end
end
