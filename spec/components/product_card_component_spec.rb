# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProductCardComponent, type: :component do
  it "shows the product name and its price in euros" do
    product = Product.new(name: "Home jersey", price_cents: 4500)

    render_inline(described_class.new(product: product))

    expect(rendered_content).to include("Home jersey")
    expect(rendered_content).to include("45,00 €")
  end
end
