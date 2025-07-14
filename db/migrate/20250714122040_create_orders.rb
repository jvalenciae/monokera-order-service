class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders do |t|
      t.bigint :customer_id
      t.string :product_name
      t.integer :quantity
      t.float :price
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
