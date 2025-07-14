require 'rails_helper'

RSpec.describe Api::V1::OrdersController, type: :controller do
  let(:customer_id) { "1" }
  let(:valid_order_params) do
    {
      order: {
        customer_id: customer_id,
        product_name: 'Test Product',
        quantity: "2",
        price: "29.99"
      }
    }
  end

  before do
    allow_any_instance_of(CustomerApiAdapter).to receive(:fetch_customer).and_return(
      double('customer', id: customer_id)
    )
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      before do
        allow(CreateOrderService).to receive(:new).and_return(
          double('service', call: build(:order))
        )
      end

      it 'returns http created' do
        post :create, params: valid_order_params
        expect(response).to have_http_status(:created)
      end

      it 'calls CreateOrderService' do
        expect(CreateOrderService).to receive(:new).with(
          ActionController::Parameters.new(valid_order_params[:order]).permit!
        ).and_return(double('service', call: build(:order)))

        post :create, params: valid_order_params
      end

      it 'returns success response' do
        post :create, params: valid_order_params

        json_response = JSON.parse(response.body)
        expect(json_response).to have_key('data')
      end
    end

    context 'with invalid parameters' do
      let(:invalid_order_params) do
        {
          order: {
            customer_id: customer_id,
            product_name: 'Test Product',
            quantity: "2"
          }
        }
      end

      it 'returns http unprocessable entity' do
        post :create, params: invalid_order_params
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error response' do
        post :create, params: invalid_order_params

        json_response = JSON.parse(response.body)
        expect(json_response).to have_key('error')
        expect(json_response['error']).to eq('Validation failed')
      end
    end
  end

  describe 'GET #index' do
    let!(:order1) { create(:order, customer_id: customer_id, product_name: 'Product 1') }
    let!(:order2) { create(:order, customer_id: customer_id, product_name: 'Product 2') }
    let!(:other_order) { create(:order, customer_id: 999, product_name: 'Other Product') }

    context 'when customer_id is provided' do
      before do
        get :index, params: { customer_id: customer_id }
      end

      it 'returns http success' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns orders for the specified customer' do
        json_response = JSON.parse(response.body)

        expect(json_response).to have_key('data')
        expect(json_response['data']).to be_an(Array)
        expect(json_response['data'].length).to eq(2)

        order_names = json_response['data'].map { |order| order['product_name'] }
        expect(order_names).to include('Product 1', 'Product 2')
        expect(order_names).not_to include('Other Product')
      end
    end

    context 'when customer_id is not provided' do
      before do
        get :index
      end

      it 'returns no orders' do
        json_response = JSON.parse(response.body)

        expect(json_response).to have_key('data')
        expect(json_response['data']).to be_an(Array)
        expect(json_response['data']).to be_empty
      end
    end

    context 'when customer has no orders' do
      before do
        get :index, params: { customer_id: 888 }
      end

      it 'returns empty array' do
        json_response = JSON.parse(response.body)

        expect(json_response).to have_key('data')
        expect(json_response['data']).to be_an(Array)
        expect(json_response['data']).to be_empty
      end
    end
  end
end
