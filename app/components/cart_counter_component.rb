# frozen_string_literal: true

class CartCounterComponent < ViewComponent::Base
  def initialize(count:)
    @count = count
  end
end
