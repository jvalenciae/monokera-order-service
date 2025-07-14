FactoryBot.define do
  factory :order do
    customer_id { Faker::Number.between(from: 1, to: 100) }
    product_name { Faker::Commerce.product_name }
    quantity { Faker::Number.between(from: 1, to: 10) }
    price { Faker::Commerce.price(range: 10..1000.0) }
    status { :pending }
  end
end
