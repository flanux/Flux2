# API Gateway

A comprehensive API Gateway built with Spring Cloud Gateway for managing microservices architecture.

## 🏗️ Architecture Overview

```
Frontend (React/Angular)
         ↓
   API Gateway (Port 8080)
         ↓
   JWT Authentication
         ↓
   Microservices
```

## 📋 Features

- **JWT Authentication & Authorization** - Secure token-based authentication
- **Route Management** - Centralized routing for all microservices
- **Circuit Breaker** - Fallback mechanisms for service failures
- **CORS Support** - Cross-origin resource sharing for frontend integration
- **Rate Limiting** - Redis-based rate limiting (optional)
- **Health Checks** - Actuator endpoints for monitoring
- **Request/Response Logging** - Debug and trace requests
- **Load Balancing** - Distribute traffic across service instances

## 🚀 Microservices Routes

| Service | Port | Gateway Route | Description |
|---------|------|---------------|-------------|
| Account Service | 8081 | `/api/accounts/**` | Account management |
| Customer Service | 8082 | `/api/customers/**` | Customer information |
| Loan Service | 8083 | `/api/loans/**` | Loan processing |
| Card Service | 8084 | `/api/cards/**` | Card management |
| Transaction Service | 8085 | `/api/transactions/**` | Transaction handling |
| Ledger Service | 8086 | `/api/ledger/**` | Ledger operations |
| Notification Service | 8087 | `/api/notifications/**` | Notifications |
| Reporting Service | 8088 | `/api/reports/**` | Report generation |
| Auth Service | 9000 | `/api/auth/**` | Authentication (Public) |

## 🔧 Prerequisites

- Java 17 or higher
- Maven 3.6+
- Redis (optional, for rate limiting)
- PostgreSQL/Oracle (for services)

## 📦 Installation

1. Clone the repository:
```bash
git clone https://github.com/flanux/api-gateway.git
cd api-gateway
```

2. Build the project:
```bash
mvn clean install
```

3. Run the application:
```bash
mvn spring-boot:run
```

Or using the JAR:
```bash
java -jar target/api-gateway-1.0.0.jar
```

## ⚙️ Configuration

### Environment Variables

Create a `.env` file or set these environment variables:

```properties
JWT_SECRET=your-secure-256-bit-secret-key-here
REDIS_HOST=localhost
REDIS_PORT=6379
```

### Application Properties

Edit `src/main/resources/application.yml` to configure:

- Service URLs
- Port numbers
- CORS allowed origins
- JWT secret and expiration
- Redis configuration

### Service URLs Configuration

Update the URIs in `application.yml` for each microservice:

```yaml
spring:
  cloud:
    gateway:
      routes:
        - id: account-service
          uri: http://localhost:8081  # Change to your service URL
```

## 🔐 Authentication Flow

### 1. Login (Public Endpoint)
```bash
POST http://localhost:8080/api/auth/login
Content-Type: application/json

{
  "username": "user@example.com",
  "password": "password123"
}
```

Response:
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "type": "Bearer",
  "expiresIn": 86400
}
```

### 2. Access Protected Resources
```bash
GET http://localhost:8080/api/accounts/123
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

## 🛡️ Security

### Public Endpoints (No Authentication Required)
- `/api/auth/login`
- `/api/auth/register`
- `/api/auth/refresh`
- `/api/auth/forgot-password`
- `/api/auth/reset-password`
- `/actuator/**`

### Protected Endpoints
All other endpoints require a valid JWT token in the Authorization header.

## 🔄 Circuit Breaker

The gateway implements circuit breaker pattern for all microservices. If a service is unavailable:

1. The circuit breaker opens
2. Requests are redirected to fallback endpoints
3. User receives a friendly error message

Example fallback response:
```json
{
  "error": "Account Service is currently unavailable",
  "message": "Please try again later. Our team has been notified.",
  "timestamp": "2026-02-04T10:30:00",
  "status": 503
}
```

## 📊 Monitoring

### Health Check
```bash
GET http://localhost:8080/actuator/health
```

### Gateway Info
```bash
GET http://localhost:8080/api/gateway/info
```

### Metrics
```bash
GET http://localhost:8080/actuator/metrics
```

## 🌐 CORS Configuration

The gateway is pre-configured to accept requests from:
- `http://localhost:3000` (React default)
- `http://localhost:4200` (Angular default)

To add more origins, update `application.yml`:

```yaml
spring:
  cloud:
    gateway:
      globalcors:
        cors-configurations:
          '[/**]':
            allowed-origins: 
              - "http://localhost:3000"
              - "https://your-production-domain.com"
```

## 🧪 Testing

### Test Gateway Health
```bash
curl http://localhost:8080/api/gateway/health
```

### Test Service Routing
```bash
# Login first
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"test","password":"test"}'

# Use the token
curl http://localhost:8080/api/accounts \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

## 📝 API Documentation

Once all services are running, you can access:
- Gateway Info: `http://localhost:8080/api/gateway/info`
- Actuator: `http://localhost:8080/actuator`

## 🐳 Docker Support

Create a `Dockerfile`:

```dockerfile
FROM openjdk:17-jdk-slim
WORKDIR /app
COPY target/api-gateway-1.0.0.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

Build and run:
```bash
docker build -t flanux/api-gateway .
docker run -p 8080:8080 flanux/api-gateway
```

## 🔨 Development

### Running in Development Mode
```bash
mvn spring-boot:run -Dspring-boot.run.profiles=dev
```

### Building for Production
```bash
mvn clean package -Pprod
```

## 📚 Integration with Frontend

### React Example
```javascript
const API_BASE_URL = 'http://localhost:8080/api';

// Login
const login = async (username, password) => {
  const response = await fetch(`${API_BASE_URL}/auth/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ username, password })
  });
  const data = await response.json();
  localStorage.setItem('token', data.token);
};

// Get Accounts
const getAccounts = async () => {
  const token = localStorage.getItem('token');
  const response = await fetch(`${API_BASE_URL}/accounts`, {
    headers: { 'Authorization': `Bearer ${token}` }
  });
  return response.json();
};
```

### Angular Example
```typescript
import { HttpClient, HttpHeaders } from '@angular/common/http';

export class ApiService {
  private apiUrl = 'http://localhost:8080/api';

  constructor(private http: HttpClient) {}

  login(username: string, password: string) {
    return this.http.post(`${this.apiUrl}/auth/login`, { username, password });
  }

  getAccounts() {
    const token = localStorage.getItem('token');
    const headers = new HttpHeaders({
      'Authorization': `Bearer ${token}`
    });
    return this.http.get(`${this.apiUrl}/accounts`, { headers });
  }
}
```

## 🚧 Roadmap

- [ ] Service Discovery (Eureka)
- [ ] API Documentation (Swagger/OpenAPI)
- [ ] Request Caching
- [ ] Advanced Rate Limiting
- [ ] GraphQL Gateway
- [ ] WebSocket Support
- [ ] Distributed Tracing (Zipkin/Jaeger)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License.

## 👥 Team

- **Developer**: Flanux
- **GitHub**: https://github.com/flanux

## 📞 Support

For issues and questions, please create an issue on GitHub.

---

**Note**: Make sure all microservices are running on their respective ports before starting the gateway.
