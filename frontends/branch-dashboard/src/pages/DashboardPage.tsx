import { useEffect, useState } from 'react'
import {
  Grid,
  Paper,
  Typography,
  Box,
  Card,
  CardContent,
  CircularProgress,
  Button,
} from '@mui/material'
import {
  TrendingUp as TrendingUpIcon,
  TrendingDown as TrendingDownIcon,
  People as PeopleIcon,
  AccountBalance as AccountBalanceIcon,
  Payment as PaymentIcon,
  MonetizationOn as MonetizationOnIcon,
} from '@mui/icons-material'
import { DashboardStats } from '../types'

const DashboardPage = () => {
  const [loading, setLoading] = useState(true)
  const [stats, setStats] = useState<DashboardStats>({
    todayTransactions: 0,
    todayDeposits: 0,
    todayWithdrawals: 0,
    totalCustomers: 0,
    activeAccounts: 0,
    pendingLoans: 0,
  })

  useEffect(() => {
    fetchDashboardStats()
  }, [])

  const fetchDashboardStats = async () => {
    try {
      // TODO: Replace with actual API call
      await new Promise((resolve) => setTimeout(resolve, 1000))
      
      setStats({
        todayTransactions: 127,
        todayDeposits: 85000,
        todayWithdrawals: 43000,
        totalCustomers: 1543,
        activeAccounts: 2187,
        pendingLoans: 12,
      })
    } catch (error) {
      console.error('Error fetching dashboard stats:', error)
    } finally {
      setLoading(false)
    }
  }

  const StatCard = ({
    title,
    value,
    icon,
    color,
    prefix = '',
  }: {
    title: string
    value: number
    icon: React.ReactNode
    color: string
    prefix?: string
  }) => (
    <Card>
      <CardContent>
        <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
          <Box
            sx={{
              bgcolor: `${color}.light`,
              color: `${color}.dark`,
              p: 1,
              borderRadius: 1,
              mr: 2,
            }}
          >
            {icon}
          </Box>
          <Typography color="text.secondary" variant="body2">
            {title}
          </Typography>
        </Box>
        <Typography variant="h4" component="div">
          {prefix}{value.toLocaleString()}
        </Typography>
      </CardContent>
    </Card>
  )

  if (loading) {
    return (
      <Box display="flex" justifyContent="center" alignItems="center" minHeight="400px">
        <CircularProgress />
      </Box>
    )
  }

  return (
    <Box>
      <Typography variant="h4" gutterBottom>
        Welcome Back!
      </Typography>
      <Typography variant="body1" color="text.secondary" sx={{ mb: 4 }}>
        Here's what's happening with your branch today
      </Typography>

      <Grid container spacing={3}>
        <Grid item xs={12} sm={6} md={4}>
          <StatCard
            title="Today's Transactions"
            value={stats.todayTransactions}
            icon={<PaymentIcon />}
            color="primary"
          />
        </Grid>
        <Grid item xs={12} sm={6} md={4}>
          <StatCard
            title="Today's Deposits"
            value={stats.todayDeposits}
            icon={<TrendingUpIcon />}
            color="success"
            prefix="$"
          />
        </Grid>
        <Grid item xs={12} sm={6} md={4}>
          <StatCard
            title="Today's Withdrawals"
            value={stats.todayWithdrawals}
            icon={<TrendingDownIcon />}
            color="error"
            prefix="$"
          />
        </Grid>
        <Grid item xs={12} sm={6} md={4}>
          <StatCard
            title="Total Customers"
            value={stats.totalCustomers}
            icon={<PeopleIcon />}
            color="info"
          />
        </Grid>
        <Grid item xs={12} sm={6} md={4}>
          <StatCard
            title="Active Accounts"
            value={stats.activeAccounts}
            icon={<AccountBalanceIcon />}
            color="secondary"
          />
        </Grid>
        <Grid item xs={12} sm={6} md={4}>
          <StatCard
            title="Pending Loans"
            value={stats.pendingLoans}
            icon={<MonetizationOnIcon />}
            color="warning"
          />
        </Grid>
      </Grid>

      <Paper sx={{ p: 3, mt: 4 }}>
        <Typography variant="h6" gutterBottom>
          Quick Actions
        </Typography>
        <Grid container spacing={2} sx={{ mt: 1 }}>
          <Grid item xs={12} sm={6} md={3}>
            <Button variant="contained" fullWidth>
              New Customer
            </Button>
          </Grid>
          <Grid item xs={12} sm={6} md={3}>
            <Button variant="contained" fullWidth>
              Open Account
            </Button>
          </Grid>
          <Grid item xs={12} sm={6} md={3}>
            <Button variant="contained" fullWidth>
              New Transaction
            </Button>
          </Grid>
          <Grid item xs={12} sm={6} md={3}>
            <Button variant="contained" fullWidth>
              Issue Card
            </Button>
          </Grid>
        </Grid>
      </Paper>
    </Box>
  )
}

export default DashboardPage
