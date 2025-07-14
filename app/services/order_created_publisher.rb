require "json"

class OrderCreatedPublisher
  def initialize(order)
    @order = order
    @connection = RabbitMqConnection.instance
    @channel = @connection.channel
  end

  def publish
    exchange = @channel.topic("orders", durable: true)

    event_payload = {
      event_type: "order_created",
      data: {
        customer_id: @order.customer_id,
        order_id: @order.id,
        product_name: @order.product_name,
        quantity: @order.quantity,
        price: @order.price
      }
    }.to_json

    exchange.publish(event_payload, routing_key: "order.created", persistent: true)
  end
end
