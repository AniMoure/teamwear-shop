require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe "#format_price" do
    it "formats cents as euros" do
      expect(helper.format_price(4500)).to eq("45,00 €")
    end

    it "uses a space as thousands separator" do
      expect(helper.format_price(123_456)).to eq("1 234,56 €")
    end
  end
end
