# Quick Start Guide for Frontend Developers

## 🎯 What You Need to Know

The API Gateway is your **single entry point** to all backend services. You don't need to worry about individual microservice URLs - everything goes through:

```
http://localhost:8080/api
```

## 🚀 Getting Started (5 minutes)

### 1. Start the Gateway
```bash
cd api-gateway
mvn spring-boot:run
```

Wait until you see: `Started ApiGatewayApplication`

### 2. Test the Gateway
```bash
curl http://localhost:8080/api/gateway/health
```

You should see:
```json
{
  "status": "UP",
  "service": "API Gateway",
  "timestamp": "2026-02-04T..."
}
```

## 🔑 Authentication Flow

### Step 1: Login
```javascript
// POST /api/auth/login
const loginResponse = await fetch('http://localhost:8080/api/auth/login', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    username: 'user@example.com',
    password: 'password123'
  })
});

const { token } = await loginResponse.json();
// Save this token!
localStorage.setItem('token', token);
```

### Step 2: Use the Token
```javascript
// GET /api/accounts (or any protected endpoint)
const accountsResponse = await fetch('http://localhost:8080/api/accounts', {
  headers: {
    'Authorization': `Bearer ${localStorage.getItem('token')}`
  }
});

const accounts = await accountsResponse.json();
```

## 📍 Available Endpoints

| Service | Endpoint | Description |
|---------|----------|-------------|
| **Auth** | `/api/auth/login` | Login (no token needed) |
| **Auth** | `/api/auth/register` | Register (no token needed) |
| **Accounts** | `/api/accounts` | Get all accounts |
| **Accounts** | `/api/accounts/:id` | Get specific account |
| **Customers** | `/api/customers` | Get all customers |
| **Loans** | `/api/loans` | Get all loans |
| **Cards** | `/api/cards` | Get all cards |
| **Transactions** | `/api/transactions` | Get transactions |
| **Notifications** | `/api/notifications` | Get notifications |
| **Reports** | `/api/reports` | Get reports |

## 🎨 React Example

### Create an API Service (`services/api.js`)

```javascript
const API_BASE_URL = 'http://localhost:8080/api';

class ApiService {
  // Login
  async login(username, password) {
    const response = await fetch(`${API_BASE_URL}/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ username, password })
    });
    
    if (!response.ok) throw new Error('Login failed');
    
    const data = await response.json();
    localStorage.setItem('token', data.token);
    return data;
  }

  // Generic GET request
  async get(endpoint) {
    const token = localStorage.getItem('token');
    const response = await fetch(`${API_BASE_URL}${endpoint}`, {
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      }
    });
    
    if (!response.ok) {
      if (response.status === 401) {
        // Token expired, redirect to login
        localStorage.removeItem('token');
        window.location.href = '/login';
      }
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    
    return response.json();
  }

  // Generic POST request
  async post(endpoint, data) {
    const token = localStorage.getItem('token');
    const response = await fetch(`${API_BASE_URL}${endpoint}`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(data)
    });
    
    if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`);
    return response.json();
  }

  // Specific methods
  getAccounts() {
    return this.get('/accounts');
  }

  getAccount(id) {
    return this.get(`/accounts/${id}`);
  }

  getCustomers() {
    return this.get('/customers');
  }

  getTransactions() {
    return this.get('/transactions');
  }
}

export default new ApiService();
```

### Use in Component

```javascript
import React, { useState, useEffect } from 'react';
import api from './services/api';

function AccountsPage() {
  const [accounts, setAccounts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    loadAccounts();
  }, []);

  const loadAccounts = async () => {
    try {
      setLoading(true);
      const data = await api.getAccounts();
      setAccounts(data);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error}</div>;

  return (
    <div>
      <h1>Accounts</h1>
      {accounts.map(account => (
        <div key={account.id}>
          <p>Account: {account.accountNumber}</p>
          <p>Balance: ${account.balance}</p>
        </div>
      ))}
    </div>
  );
}
```

## 🅰️ Angular Example

### Create API Service (`services/api.service.ts`)

```typescript
import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class ApiService {
  private baseUrl = 'http://localhost:8080/api';

  constructor(private http: HttpClient) {}

  private getHeaders(): HttpHeaders {
    const token = localStorage.getItem('token');
    return new HttpHeaders({
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    });
  }

  login(username: string, password: string): Observable<any> {
    return this.http.post(`${this.baseUrl}/auth/login`, { username, password });
  }

  getAccounts(): Observable<any[]> {
    return this.http.get<any[]>(`${this.baseUrl}/accounts`, { 
      headers: this.getHeaders() 
    });
  }

  getCustomers(): Observable<any[]> {
    return this.http.get<any[]>(`${this.baseUrl}/customers`, { 
      headers: this.getHeaders() 
    });
  }

  getTransactions(): Observable<any[]> {
    return this.http.get<any[]>(`${this.baseUrl}/transactions`, { 
      headers: this.getHeaders() 
    });
  }
}
```

### Use in Component

```typescript
import { Component, OnInit } from '@angular/core';
import { ApiService } from '../services/api.service';

@Component({
  selector: 'app-accounts',
  templateUrl: './accounts.component.html'
})
export class AccountsComponent implements OnInit {
  accounts: any[] = [];
  loading = true;
  error: string | null = null;

  constructor(private apiService: ApiService) {}

  ngOnInit() {
    this.loadAccounts();
  }

  loadAccounts() {
    this.apiService.getAccounts().subscribe({
      next: (data) => {
        this.accounts = data;
        this.loading = false;
      },
      error: (err) => {
        this.error = err.message;
        this.loading = false;
      }
    });
  }
}
```

## ⚠️ Common Issues & Solutions

### Issue: CORS Error
**Solution**: The gateway already handles CORS. Make sure you're using `http://localhost:3000` or `http://localhost:4200`.

### Issue: 401 Unauthorized
**Solution**: Your token is missing or expired. Login again.

### Issue: Gateway not responding
**Solution**: Make sure the gateway is running on port 8080:
```bash
curl http://localhost:8080/api/gateway/health
```

### Issue: Service Unavailable (503)
**Solution**: The microservice is down. You'll get a fallback response. Check that the service is running.

## 🧪 Testing with Postman

1. Import `postman_collection.json` into Postman
2. Set the `base_url` variable to `http://localhost:8080`
3. Login using the Login request
4. Copy the token from response
5. Set `jwt_token` variable with the token
6. Now all requests will include the token automatically

## 📝 Notes for Frontend Team

1. **All requests go through port 8080** - Don't connect to individual services
2. **Always include the token** - Except for `/api/auth/*` endpoints
3. **Handle 401 errors** - Token expired, redirect to login
4. **Handle 503 errors** - Service temporarily unavailable
5. **Use the token format**: `Bearer YOUR_TOKEN_HERE`

## 🎉 You're Ready!

The gateway handles:
- ✅ Routing to correct microservices
- ✅ Authentication & authorization
- ✅ CORS
- ✅ Error handling
- ✅ Service failures (circuit breaker)

You just need to:
- 📱 Build the UI
- 🔌 Call the API endpoints
- 🎨 Display the data

Happy coding! 🚀
