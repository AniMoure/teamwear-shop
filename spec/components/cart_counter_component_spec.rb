# frozen_string_literal: true

require "rails_helper"

RSpec.describe CartCounterComponent, type: :component do
  it "shows the number of items with an id Turbo can target" do
    html = render_inline(described_class.new(count: 3))

    expect(html.css("#cart_counter").text).to eq("Cart (3)")
  end

  it "links to the cart page" do
    html = render_inline(described_class.new(count: 3))

    expect(html.css("a#cart_counter").attr("href").value).to eq("/cart")
  end
end
