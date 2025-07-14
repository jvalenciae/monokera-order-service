class CreateOrderService
  def initialize(order_params)
    @order_params = order_params
  end

  def call
    customer = CustomerApiAdapter.new(@order_params[:customer_id]).fetch_customer

    order = Order.create!(@order_params)

    OrderCreatedPublisher.new(order).publish

    order
  end
end
