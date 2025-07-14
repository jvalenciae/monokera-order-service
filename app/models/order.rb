class Order < ApplicationRecord
  validates :customer_id, :product_name, :quantity, :price, presence: true

  enum :status, {
    pending: 0,
    shipped: 1,
    delivered: 2,
    cancelled: 3
  }
end
