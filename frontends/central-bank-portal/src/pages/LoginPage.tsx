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
