module ApplicationHelper
  # Prices are stored as integer cents; this turns 123456 into "1 234,56 €".
  def format_price(cents)
    number_to_currency(cents.to_d / 100, unit: "€", separator: ",", delimiter: " ", format: "%n %u")
  end
end
