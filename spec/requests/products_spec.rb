require "rails_helper"

RSpec.describe "Products", type: :request do
  describe "GET /products" do
    it "lists the products with their price" do
      Product.create!(name: "Home jersey", price_cents: 4500)

      get products_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Home jersey")
      expect(response.body).to include("45,00 €")
    end
  end
end
