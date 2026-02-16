#!/bin/bash

# Flux2 Complete Fix Script
# Fixes: Kafka dependencies + Frontend authentication

echo "=========================================="
echo "Flux2 Complete Fix Script"
echo "=========================================="

# Check if we're in the Flux2 directory
if [ ! -f "docker-compose.yml" ]; then
    echo "Error: Please run this script from the Flux2 root directory"
    exit 1
fi

echo ""
echo "============================================"
echo "PART 1: Adding Kafka Dependencies to Services"
echo "============================================"

# Function to add Kafka dependency to pom.xml
add_kafka_dependency() {
    local pom_file=$1
    local service_name=$2
    
    if grep -q "spring-kafka" "$pom_file"; then
        echo "  [SKIP] $service_name already has spring-kafka"
        return
    fi
    
    # Add spring-kafka dependency before closing </dependencies>
    sed -i 's|</dependencies>|        <dependency>\n                <groupId>org.springframework.kafka</groupId>\n                <artifactId>spring-kafka</artifactId>\n        </dependency>\n</dependencies>|' "$pom_file"
    echo "  [OK] Added spring-kafka to $service_name"
}

# Add Kafka dependency to all services that need it
echo ""
echo "Adding spring-kafka dependency to services..."

SERVICES="transaction-service notification-service reporting-service loan-service ledger-service card-service account-service"

for service in $SERVICES; do
    pom_file="services/$service/pom.xml"
    if [ -f "$pom_file" ]; then
        add_kafka_dependency "$pom_file" "$service"
    fi
done

echo ""
echo "============================================"
echo "PART 2: Fixing Frontend Authentication"
echo "============================================"

echo ""
echo "[1/6] Fixing customer-portal authService.ts..."

mkdir -p frontends/customer-portal/src/services

cat > frontends/customer-portal/src/services/authService.ts << 'EOF'
import api from './api';
import { LoginRequest, LoginResponse } from '../types';

interface BackendLoginResponse {
  accessToken: string;
  refreshToken: string;
  tokenType: string;
  expiresIn: number;
  user: {
    id: number;
    username: string;
    email: string;
    role: string;
    customerId?: number;
    branchId?: number;
  };
}

class AuthService {
  async login(credentials: LoginRequest): Promise<LoginResponse> {
    const { data } = await api.post<BackendLoginResponse>('/auth/login', credentials);
    
    // Map backend response to frontend expected format
    const token = data.accessToken;
    const user = {
      ...data.user,
      firstName: data.user.username,
      lastName: '',
    };
    
    localStorage.setItem('authToken', token);
    localStorage.setItem('userData', JSON.stringify(user));
    
    return { token, user };
  }
  
  async logout() {
    await api.post('/auth/logout');
    localStorage.removeItem('authToken');
    localStorage.removeItem('userData');
  }
  
  getCurrentUser() {
    const userData = localStorage.getItem('userData');
    return userData ? JSON.parse(userData) : null;
  }
  
  isAuthenticated() {
    return !!localStorage.getItem('authToken');
  }
}

export default new AuthService();
EOF

echo "[2/6] Fixing customer-portal types/index.ts..."

mkdir -p frontends/customer-portal/src/types

cat > frontends/customer-portal/src/types/index.ts << 'EOF'
export interface User {
  id: number;
  username: string;
  email: string;
  firstName?: string;
  lastName?: string;
  customerId?: number;
  branchId?: number;
  role: string;
}

export interface LoginRequest {
  username: string;
  password: string;
}

export interface LoginResponse {
  token: string;
  user: User;
}

export interface Account {
  id: number;
  accountNumber: string;
  accountType: 'SAVINGS' | 'CHECKING' | 'FIXED_DEPOSIT';
  balance: number;
  currency: string;
  status: 'ACTIVE' | 'INACTIVE' | 'FROZEN';
}

export interface Transaction {
  id: number;
  transactionId: string;
  amount: number;
  currency: string;
  transactionType: 'DEPOSIT' | 'WITHDRAWAL' | 'TRANSFER';
  transactionStatus: 'COMPLETED' | 'PENDING' | 'FAILED';
  description: string;
  createdAt: string;
}

export interface Loan {
  id: number;
  loanNumber: string;
  loanType: 'PERSONAL' | 'HOME' | 'AUTO';
  principalAmount: number;
  outstandingBalance: number;
  interestRate: number;
  monthlyPayment: number;
  nextPaymentDate: string;
  loanStatus: 'ACTIVE' | 'PAID_OFF';
}

export interface Card {
  id: number;
  lastFourDigits: string;
  cardType: 'DEBIT' | 'CREDIT';
  expiryDate: string;
  status: 'ACTIVE' | 'BLOCKED';
}

export interface ApiResponse<T> {
  success: boolean;
  data: T;
  message?: string;
}
EOF

echo "[3/6] Fixing branch-dashboard api.ts..."

mkdir -p frontends/branch-dashboard/src/services

cat > frontends/branch-dashboard/src/services/api.ts << 'EOF'
import axios from 'axios'
import { toast } from 'react-toastify'

const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:8089'

const api = axios.create({
  baseURL: `${API_BASE_URL}/api`,
  headers: {
    'Content-Type': 'application/json',
  },
})

// Request interceptor
api.interceptors.request.use(
  (config) => {
    const authData = localStorage.getItem('auth-storage')
    if (authData) {
      const { state } = JSON.parse(authData)
      if (state?.token) {
        config.headers.Authorization = `Bearer ${state.token}`
      }
    }
    return config
  },
  (error) => Promise.reject(error)
)

// Response interceptor
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('auth-storage')
      window.location.href = '/login'
      toast.error('Session expired. Please login again.')
    } else if (error.response?.data?.message) {
      toast.error(error.response.data.message)
    } else {
      toast.error('An error occurred. Please try again.')
    }
    return Promise.reject(error)
  }
)

export default api
EOF

echo "[4/6] Fixing branch-dashboard LoginPage.tsx..."

mkdir -p frontends/branch-dashboard/src/pages

cat > frontends/branch-dashboard/src/pages/LoginPage.tsx << 'EOF'
import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import {
  Container,
  Box,
  Paper,
  TextField,
  Button,
  Typography,
  Avatar,
  CircularProgress,
} from '@mui/material'
import { AccountBalance as AccountBalanceIcon } from '@mui/icons-material'
import { toast } from 'react-toastify'
import { useAuthStore } from '../store/authStore'
import api from '../services/api'

const LoginPage = () => {
  const [formData, setFormData] = useState({
    username: '',
    password: '',
  })
  const [loading, setLoading] = useState(false)
  const navigate = useNavigate()
  const login = useAuthStore((state) => state.login)

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value,
    })
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)

    try {
      const response = await api.post('/auth/login', {
        username: formData.username,
        password: formData.password,
      })

      if (response.data) {
        // Backend returns accessToken, map to token
        const token = response.data.accessToken || response.data.token
        const user = response.data.user
        login(user, token)
        toast.success('Login successful!')
        navigate('/dashboard')
      }
    } catch (error: any) {
      console.error('Login error:', error)
      toast.error(error.response?.data?.error || 'Invalid credentials')
    } finally {
      setLoading(false)
    }
  }

  return (
    <Container component="main" maxWidth="xs">
      <Box
        sx={{
          minHeight: '100vh',
          display: 'flex',
          flexDirection: 'column',
          justifyContent: 'center',
          alignItems: 'center',
        }}
      >
        <Paper
          elevation={3}
          sx={{
            p: 4,
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            width: '100%',
          }}
        >
          <Avatar sx={{ m: 1, bgcolor: 'primary.main', width: 56, height: 56 }}>
            <AccountBalanceIcon fontSize="large" />
          </Avatar>
          <Typography component="h1" variant="h5" sx={{ mb: 3 }}>
            Branch Portal Login
          </Typography>
          <Box component="form" onSubmit={handleSubmit} sx={{ width: '100%' }}>
            <TextField
              margin="normal"
              required
              fullWidth
              id="username"
              label="Username"
              name="username"
              autoComplete="username"
              autoFocus
              value={formData.username}
              onChange={handleChange}
            />
            <TextField
              margin="normal"
              required
              fullWidth
              name="password"
              label="Password"
              type="password"
              id="password"
              autoComplete="current-password"
              value={formData.password}
              onChange={handleChange}
            />
            <Button
              type="submit"
              fullWidth
              variant="contained"
              sx={{ mt: 3, mb: 2 }}
              disabled={loading}
            >
              {loading ? <CircularProgress size={24} /> : 'Sign In'}
            </Button>
            <Typography variant="body2" color="text.secondary" align="center">
              Demo: manager.ktm / Flux@2026
            </Typography>
          </Box>
        </Paper>
      </Box>
    </Container>
  )
}

export default LoginPage
EOF

echo "[5/6] Fixing central-bank-portal api.ts..."

mkdir -p frontends/central-bank-portal/src/services

cat > frontends/central-bank-portal/src/services/api.ts << 'EOF'
import axios from 'axios'
import { toast } from 'react-toastify'

const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:8089'

const api = axios.create({
  baseURL: `${API_BASE_URL}/api`,
  headers: {
    'Content-Type': 'application/json',
  },
})

// Request interceptor
api.interceptors.request.use(
  (config) => {
    const authData = localStorage.getItem('central-bank-auth')
    if (authData) {
      const { state } = JSON.parse(authData)
      if (state?.token) {
        config.headers.Authorization = `Bearer ${state.token}`
      }
    }
    return config
  },
  (error) => Promise.reject(error)
)

// Response interceptor
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('central-bank-auth')
      window.location.href = '/login'
      toast.error('Session expired. Please login again.')
    } else if (error.response?.data?.message) {
      toast.error(error.response.data.message)
    } else {
      toast.error('An error occurred. Please try again.')
    }
    return Promise.reject(error)
  }
)

export default api
EOF

echo "[6/6] Fixing central-bank-portal LoginPage.tsx..."

mkdir -p frontends/central-bank-portal/src/pages

cat > frontends/central-bank-portal/src/pages/LoginPage.tsx << 'EOF'
import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import {
  Container,
  Box,
  Paper,
  TextField,
  Button,
  Typography,
  Avatar,
  CircularProgress,
} from '@mui/material'
import { AccountBalance as AccountBalanceIcon } from '@mui/icons-material'
import { toast } from 'react-toastify'
import { useAuthStore } from '../store/authStore'
import api from '../services/api'

const LoginPage = () => {
  const [formData, setFormData] = useState({
    username: '',
    password: '',
  })
  const [loading, setLoading] = useState(false)
  const navigate = useNavigate()
  const login = useAuthStore((state) => state.login)

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value,
    })
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)

    try {
      const response = await api.post('/auth/login', {
        username: formData.username,
        password: formData.password,
      })

      if (response.data) {
        // Backend returns accessToken, map to token
        const token = response.data.accessToken || response.data.token
        const user = response.data.user
        login(user, token)
        toast.success('Login successful!')
        navigate('/overview')
      }
    } catch (error: any) {
      console.error('Login error:', error)
      toast.error(error.response?.data?.error || 'Invalid credentials')
    } finally {
      setLoading(false)
    }
  }

  return (
    <Container component="main" maxWidth="xs">
      <Box
        sx={{
          minHeight: '100vh',
          display: 'flex',
          flexDirection: 'column',
          justifyContent: 'center',
          alignItems: 'center',
        }}
      >
        <Paper
          elevation={3}
          sx={{
            p: 4,
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            width: '100%',
          }}
        >
          <Avatar sx={{ m: 1, bgcolor: 'primary.main', width: 56, height: 56 }}>
            <AccountBalanceIcon fontSize="large" />
          </Avatar>
          <Typography component="h1" variant="h5" sx={{ mb: 1 }}>
            Central Bank Portal
          </Typography>
          <Typography variant="body2" color="text.secondary" sx={{ mb: 3 }}>
            System Administration
          </Typography>
          <Box component="form" onSubmit={handleSubmit} sx={{ width: '100%' }}>
            <TextField
              margin="normal"
              required
              fullWidth
              id="username"
              label="Username"
              name="username"
              autoComplete="username"
              autoFocus
              value={formData.username}
              onChange={handleChange}
            />
            <TextField
              margin="normal"
              required
              fullWidth
              name="password"
              label="Password"
              type="password"
              id="password"
              autoComplete="current-password"
              value={formData.password}
              onChange={handleChange}
            />
            <Button
              type="submit"
              fullWidth
              variant="contained"
              sx={{ mt: 3, mb: 2 }}
              disabled={loading}
            >
              {loading ? <CircularProgress size={24} /> : 'Sign In'}
            </Button>
            <Typography variant="body2" color="text.secondary" align="center">
              Demo: admin / Flux@2026
            </Typography>
          </Box>
        </Paper>
      </Box>
    </Container>
  )
}

export default LoginPage
EOF

echo ""
echo "=========================================="
echo "All fixes applied!"
echo "=========================================="
echo ""
echo "Changes made:"
echo "  [BACKEND] Added spring-kafka dependency to services:"
echo "    - transaction-service"
echo "    - notification-service"
echo "    - reporting-service"
echo "    - loan-service"
echo "    - ledger-service"
echo "    - card-service"
echo "    - account-service"
echo ""
echo "  [FRONTEND] Fixed authentication in all 3 portals:"
echo "    - customer-portal"
echo "    - branch-dashboard"
echo "    - central-bank-portal"
echo ""
echo "=========================================="
echo "Now rebuild and restart:"
echo "=========================================="
echo ""
echo "  docker-compose down"
echo "  docker-compose up --build -d"
echo ""
echo "Wait 2-3 minutes for all services to start."
echo ""
echo "Test credentials:"
echo "  - Customer Portal: ram.bahadur / Flux@2026"
echo "  - Branch Dashboard: manager.ktm / Flux@2026"
echo "  - Central Bank Portal: admin / Flux@2026"
echo ""
