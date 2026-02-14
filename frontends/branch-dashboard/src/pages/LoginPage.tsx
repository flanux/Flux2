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
} from '@mui/material'
import { AccountBalance as AccountBalanceIcon } from '@mui/icons-material'
import { toast } from 'react-toastify'
import { useAuthStore } from '../store/authStore'

const LoginPage = () => {
  const [formData, setFormData] = useState({
    username: '',
    password: '',
    branchCode: '',
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
      // TODO: Replace with actual API call
      // const response = await api.post('/auth/branch/login', formData)
      
      // Simulated login
      await new Promise((resolve) => setTimeout(resolve, 1000))

      const mockUser = {
        id: '1',
        username: formData.username,
        name: formData.username.charAt(0).toUpperCase() + formData.username.slice(1),
        email: `${formData.username}@bank.com`,
        role: 'Branch Manager',
        branchCode: formData.branchCode,
        branchName: `Branch ${formData.branchCode}`,
      }

      login(mockUser, 'mock-jwt-token')
      toast.success('Login successful!')
      navigate('/dashboard')
    } catch (error) {
      toast.error('Invalid credentials')
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
            <TextField
              margin="normal"
              required
              fullWidth
              name="branchCode"
              label="Branch Code"
              id="branchCode"
              value={formData.branchCode}
              onChange={handleChange}
            />
            <Button
              type="submit"
              fullWidth
              variant="contained"
              sx={{ mt: 3, mb: 2 }}
              disabled={loading}
            >
              {loading ? 'Signing In...' : 'Sign In'}
            </Button>
          </Box>
        </Paper>
      </Box>
    </Container>
  )
}

export default LoginPage
