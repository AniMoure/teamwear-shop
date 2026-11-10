[
  [ "Home jersey", 4500 ],
  [ "Away jersey", 4500 ],
  [ "Training shorts", 2900 ],
  [ "Club hoodie", 5900 ]
].each do |name, price_cents|
  Product.find_or_create_by!(name: name) { |product| product.price_cents = price_cents }
end

if Cart.none?
  home_jersey = Product.find_by!(name: "Home jersey")
  away_jersey = Product.find_by!(name: "Away jersey")
  shorts = Product.find_by!(name: "Training shorts")
  hoodie = Product.find_by!(name: "Club hoodie")

  # A cart with several different products
  team_cart = Cart.create!
  CartItem.create!(cart: team_cart, product: home_jersey, quantity: 12)
  CartItem.create!(cart: team_cart, product: shorts, quantity: 12)
  CartItem.create!(cart: team_cart, product: hoodie, quantity: 3)

  # A small cart with the default quantity
  small_cart = Cart.create!
  CartItem.create!(cart: small_cart, product: away_jersey)

  # An empty cart
  Cart.create!
end
