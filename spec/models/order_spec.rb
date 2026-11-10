require "rails_helper"

RSpec.describe Order, type: :model do
  let(:jersey) { Product.create!(name: "Home jersey", price_cents: 4500) }
  let(:shorts) { Product.create!(name: "Training shorts", price_cents: 2900) }
  let(:cart) do
    Cart.create!.tap do |cart|
      CartItem.create!(cart: cart, product: jersey, quantity: 2)
      CartItem.create!(cart: cart, product: shorts, quantity: 1)
    end
  end
  let(:customer) { { customer_name: "Ana", email: "ana@example.com" } }

  describe "validations" do
    it "requires a customer name" do
      order = Order.new(email: "ana@example.com")
      order.validate

      expect(order.errors[:customer_name]).to be_present
    end

    it "requires a valid email" do
      order = Order.new(customer_name: "Ana", email: "not-an-email")
      order.validate

      expect(order.errors[:email]).to be_present
    end

    it "normalizes the email" do
      expect(Order.new(email: "  Ana@Example.COM ").email).to eq("ana@example.com")
    end
  end

  describe ".place" do
    it "creates an order with one line per cart line" do
      order = Order.place(cart: cart, **customer)

      expect(order).to be_persisted
      lines = order.order_items.order(:product_name).map { |i| [ i.product_name, i.unit_price_cents, i.quantity ] }
      expect(lines).to eq([ [ "Home jersey", 4500, 2 ], [ "Training shorts", 2900, 1 ] ])
      expect(order.total_cents).to eq(11_900)
    end

    it "keeps the price paid when the product price changes later" do
      order = Order.place(cart: cart, **customer)

      jersey.update!(price_cents: 9900)

      expect(order.reload.order_items.find_by(product: jersey).unit_price_cents).to eq(4500)
      expect(order.total_cents).to eq(11_900)
    end

    it "empties the cart" do
      Order.place(cart: cart, **customer)

      expect(Cart.exists?(cart.id)).to be(false)
      expect(CartItem.where(cart_id: cart.id)).to be_empty
    end

    it "does not create an order and keeps the cart when the customer details are invalid" do
      cart # create it before counting

      order = nil
      expect { order = Order.place(cart: cart, customer_name: "", email: "ana@example.com") }.not_to change(Order, :count)

      expect(order.errors[:customer_name]).to be_present
      expect(Cart.exists?(cart.id)).to be(true)
    end

    it "refuses an empty cart" do
      order = Order.place(cart: Cart.create!, **customer)

      expect(order).not_to be_persisted
      expect(order.errors[:base]).to include("Your cart is empty.")
    end

    it "refuses a missing cart" do
      order = Order.place(cart: nil, **customer)

      expect(order.errors[:base]).to include("Your cart is empty.")
    end

    it "refuses a cart already ordered by another request (double submit)" do
      cart_in_this_request = Cart.find(cart.id)
      Order.place(cart: cart, **customer)

      expect { Order.place(cart: cart_in_this_request, **customer) }.not_to change(Order, :count)
    end
  end

  it "has a readable order number" do
    order = Order.place(cart: cart, **customer)

    expect(order.number).to eq(format("TW-%06d", order.id))
  end

  it "has a random token used in its URL instead of its id" do
    order = Order.place(cart: cart, **customer)

    expect(order.token).to be_present
    expect(order.to_param).to eq(order.token)
  end
end
