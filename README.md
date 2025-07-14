# 🏪 Order Service

A Rails API microservice that handles order creation, validates customers, and publishes events to trigger order count updates.

## 🏗️ Architecture

This service is part of a microservices architecture that includes:
- **Customer Service** - Manages customer data and order counts
- **Order Service** (this service) - Handles order creation and publishes events
- **RabbitMQ** - Message broker for event-driven communication

### Event Flow
```
Order Service → RabbitMQ → Customer Service
     ↓              ↓              ↓
Creates Order → Publishes Event → Updates Order Count
```

## 🚀 Quick Start

### Prerequisites
- Ruby 3.2.8
- Rails 8.0.2
- PostgreSQL
- Docker (for RabbitMQ)

### 1. Setup RabbitMQ
```bash
docker run -it --rm --name rabbitmq -p 5672:5672 -p 15672:15672 rabbitmq:4-management
```

### 2. Install Dependencies
```bash
bundle install
```

### 3. Database Setup
```bash
# Create and migrate database
rails db:create
rails db:migrate

# Seed with sample data
rails db:seed
```

### 4. Start the Server
```bash
rails server -p 3000
```

## 🔧 Environment Variables

Create a `.env` file in the root directory:

```bash
# Database
DATABASE_URL=postgresql://localhost/order_service_development
```

## 📡 API Endpoints

### POST /api/v1/orders

Creates a new order and publishes an event.

**Request:**
```bash
curl -X POST http://localhost:3000/api/v1/orders \
  -H "Content-Type: application/json" \
  -d '{
    "order": {
      "customer_id": 1,
      "product_name": "Book",
      "quantity": 2,
      "price": 29.99
    }
  }'
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 123,
    "customer_id": 1,
    "product_name": "Book",
    "quantity": 2,
    "price": 29.99,
    "status": "pending",
    "created_at": "2025-07-14T10:00:00.000Z",
    "updated_at": "2025-07-14T10:00:00.000Z"
  }
}
```

### GET /api/v1/orders?customer_id=1

Retrieves orders for a specific customer.

**Request:**
```bash
curl "http://localhost:3000/api/v1/orders?customer_id=1"
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 123,
      "customer_id": 1,
      "product_name": "Book",
      "quantity": 2,
      "price": 29.99,
      "status": "pending",
      "created_at": "2025-07-14T10:00:00.000Z",
      "updated_at": "2025-07-14T10:00:00.000Z"
    }
  ]
}
```

## 🎯 Event Publishing

### Order Created Events

When an order is created, the service automatically publishes an event to RabbitMQ.

**Event Format:**
```json
{
  "event_type": "order_created",
  "data": {
    "customer_id": 1,
    "order_id": 123,
    "product_name": "Book",
    "quantity": 2,
    "price": 29.99
  }
}
```

**Publishing Flow:**
1. Validates order parameters
2. Verifies customer exists via Customer Service API
3. Creates order in database
4. Publishes `order_created` event to RabbitMQ
5. Returns order data to client

## 🏛️ Design Patterns

### Service Object Pattern
- `CreateOrderService`    - Handles order creation logic
- `OrderCreatedPublisher` - Handles RabbitMQ Publisher logic
- Encapsulates business logic in reusable services

### Adapter Pattern
- `CustomerApiAdapter` - Handles HTTP communication with Customer Service
- Provides consistent interface for external service calls

### Singleton Pattern
- `RabbitMQConnection` - Manages single RabbitMQ connection instance
- Ensures efficient resource usage across the application

## 🧪 Testing

### Run All Tests
```bash
bundle exec rspec
```

## 📊 Database Schema

### Orders Table
```sql
CREATE TABLE orders (
  id BIGSERIAL PRIMARY KEY,
  customer_id BIGINT NOT NULL,
  product_name VARCHAR NOT NULL,
  quantity INTEGER NOT NULL,
  price FLOAT NOT NULL,
  status INTEGER DEFAULT 0,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);
```

### Order Status Enum
- `0` - pending
- `1` - shipped
- `2` - delivered
- `3` - cancelled

## 🔍 Monitoring

### RabbitMQ Management Interface
- **URL**: http://localhost:15672
- **Username**: guest
- **Password**: guest

## 📦 Dependencies

### Key Gems
- `rails` - Web framework
- `pg` - PostgreSQL adapter
- `bunny` - RabbitMQ client
- `faraday` - HTTP client for Customer Service calls
- `rspec-rails` - Testing framework
- `factory_bot_rails` - Test data factories
- `faker` - Fake data generation

## 🤝 Integration with Customer Service

This service integrates with the Customer Service through:

1. **HTTP API Calls**: Verifies customer exists before creating orders
2. **Event Publishing**: Publishes events that Customer Service listens to
3. **Data Consistency**: Ensures orders are only created for valid customers

## 🧪 Testing the Full Flow

### 1. Start All Services
```bash
# Terminal 1: RabbitMQ
docker run -it --rm --name rabbitmq -p 5672:5672 -p 15672:15672 rabbitmq:4-management

# Terminal 2: Customer Service
cd customer_service
rails server -p 3001

# Terminal 4: Order Service
cd order_service
rails server -p 3000
```

### 2. Test Order Creation
```bash
# Create an order
curl -X POST http://localhost:3000/api/v1/orders \
  -H "Content-Type: application/json" \
  -d '{
    "order": {
      "customer_id": 1,
      "product_name": "Test Book",
      "quantity": 2,
      "price": 29.99
    }
  }'

# Check customer order count
curl http://localhost:3001/api/v1/customers/1
```
