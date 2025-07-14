module Api
  module V1
    class OrdersController < ApplicationController
      def create
        result = CreateOrderService.new(order_params).call

        render_success(result, status: :created)
      end

      def index
        orders = Order.where(customer_id: params[:customer_id])

        render_success(orders)
      end

      private

      def order_params
        params.require(:order).permit(:customer_id, :product_name, :quantity, :price)
      end
    end
  end
end
