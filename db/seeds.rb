[
  [ "Home jersey", 4500 ],
  [ "Away jersey", 4500 ],
  [ "Training shorts", 2900 ],
  [ "Club hoodie", 5900 ]
].each do |name, price_cents|
  Product.find_or_create_by!(name: name) { |product| product.price_cents = price_cents }
end
