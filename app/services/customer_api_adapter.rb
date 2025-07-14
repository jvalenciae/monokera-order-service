require "faraday"

class CustomerApiAdapter
  def initialize(customer_id)
    @customer_id = customer_id
    @base_url = ENV.fetch("CUSTOMER_SERVICE_URL", "http://localhost:3001")
  end

  def fetch_customer
    response = Faraday.get("#{@base_url}/api/v1/customers/#{@customer_id}")

    case response.status
    when 200
      parse_success_response(response)
    when 404
      raise ArgumentError, "Customer with ID #{@customer_id} not found"
    when 500
      raise ArgumentError, "Customer service is unavailable"
    else
      raise ArgumentError, "Failed to fetch customer: HTTP #{response.status}"
    end
  end

  private

  def parse_success_response(response)
    JSON.parse(response.body)["data"]
  end
end
