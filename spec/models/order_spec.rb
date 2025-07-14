require 'rails_helper'

RSpec.describe Order, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:customer_id) }
    it { is_expected.to validate_presence_of(:product_name) }
    it { is_expected.to validate_presence_of(:quantity) }
    it { is_expected.to validate_presence_of(:price) }
  end

  describe "enums" do
    it { is_expected.to define_enum_for(:status).with_values(pending: 0, shipped: 1, delivered: 2, cancelled: 3) }
  end
end
