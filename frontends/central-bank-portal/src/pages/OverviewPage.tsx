import { useEffect, useState } from 'react'
import {
  Grid,
  Paper,
  Typography,
  Box,
  Card,
  CardContent,
  CircularProgress,
} from '@mui/material'
import {
  AccountBalance as AccountBalanceIcon,
  People as PeopleIcon,
  TrendingUp as TrendingUpIcon,
  Payment as PaymentIcon,
  WaterDrop as WaterDropIcon,
  Check as CheckIcon,
} from '@mui/icons-material'
import { LineChart, Line, BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts'
import { SystemStats } from '../types'

const OverviewPage = () => {
  const [loading, setLoading] = useState(true)
  const [stats, setStats] = useState<SystemStats>({
    totalBranches: 0,
    activeBranches: 0,
    totalCustomers: 0,
    totalAccounts: 0,
    systemDeposits: 0,
    systemLoans: 0,
    todayTransactions: 0,
    systemLiquidity: 0,
  })

  const [chartData, setChartData] = useState([
    { month: 'Jan', deposits: 45000000, loans: 32000000 },
    { month: 'Feb', deposits: 52000000, loans: 38000000 },
    { month: 'Mar', deposits: 48000000, loans: 35000000 },
    { month: 'Apr', deposits: 61000000, loans: 42000000 },
    { month: 'May', deposits: 55000000, loans: 40000000 },
    { month: 'Jun', deposits: 67000000, loans: 47000000 },
  ])

  const [branchData, setbranchData] = useState([
    { branch: 'Branch A', performance: 92 },
    { branch: 'Branch B', performance: 88 },
    { branch: 'Branch C', performance: 85 },
    { branch: 'Branch D', performance: 78 },
    { branch: 'Branch E', performance: 95 },
  ])

  useEffect(() => {
    fetchSystemStats()
  }, [])

  const fetchSystemStats = async () => {
    try {
      // TODO: Replace with actual API call
      await new Promise((resolve) => setTimeout(resolve, 1000))
      
      setStats({
        totalBranches: 24,
        activeBranches: 23,
        totalCustomers: 48532,
        totalAccounts: 65821,
        systemDeposits: 478500000,
        systemLoans: 312400000,
        todayTransactions: 3847,
        systemLiquidity: 92.5,
      })
    } catch (error) {
      console.error('Error fetching system stats:', error)
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
    suffix = '',
  }: {
    title: string
    value: number | string
    icon: React.ReactNode
    color: string
    prefix?: string
    suffix?: string
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
          {prefix}{typeof value === 'number' ? value.toLocaleString() : value}{suffix}
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
        System Overview
      </Typography>
      <Typography variant="body1" color="text.secondary" sx={{ mb: 4 }}>
        Banking system performance and metrics
      </Typography>

      <Grid container spacing={3}>
        <Grid item xs={12} sm={6} md={3}>
          <StatCard
            title="Total Branches"
            value={stats.totalBranches}
            icon={<AccountBalanceIcon />}
            color="primary"
          />
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <StatCard
            title="Active Branches"
            value={stats.activeBranches}
            icon={<CheckIcon />}
            color="success"
          />
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <StatCard
            title="Total Customers"
            value={stats.totalCustomers}
            icon={<PeopleIcon />}
            color="info"
          />
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <StatCard
            title="Total Accounts"
            value={stats.totalAccounts}
            icon={<AccountBalanceIcon />}
            color="secondary"
          />
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <StatCard
            title="System Deposits"
            value={stats.systemDeposits}
            icon={<TrendingUpIcon />}
            color="success"
            prefix="$"
          />
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <StatCard
            title="System Loans"
            value={stats.systemLoans}
            icon={<TrendingUpIcon />}
            color="warning"
            prefix="$"
          />
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <StatCard
            title="Today's Transactions"
            value={stats.todayTransactions}
            icon={<PaymentIcon />}
            color="primary"
          />
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <StatCard
            title="System Liquidity"
            value={stats.systemLiquidity}
            icon={<WaterDropIcon />}
            color="info"
            suffix="%"
          />
        </Grid>
      </Grid>

      <Grid container spacing={3} sx={{ mt: 2 }}>
        <Grid item xs={12} md={8}>
          <Paper sx={{ p: 3 }}>
            <Typography variant="h6" gutterBottom>
              System Deposits & Loans (Last 6 Months)
            </Typography>
            <ResponsiveContainer width="100%" height={300}>
              <LineChart data={chartData}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="month" />
                <YAxis />
                <Tooltip />
                <Legend />
                <Line type="monotone" dataKey="deposits" stroke="#66bb6a" strokeWidth={2} name="Deposits ($)" />
                <Line type="monotone" dataKey="loans" stroke="#ffa726" strokeWidth={2} name="Loans ($)" />
              </LineChart>
            </ResponsiveContainer>
          </Paper>
        </Grid>

        <Grid item xs={12} md={4}>
          <Paper sx={{ p: 3 }}>
            <Typography variant="h6" gutterBottom>
              Branch Performance Score
            </Typography>
            <ResponsiveContainer width="100%" height={300}>
              <BarChart data={branchData} layout="horizontal">
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis type="number" domain={[0, 100]} />
                <YAxis type="category" dataKey="branch" width={80} />
                <Tooltip />
                <Bar dataKey="performance" fill="#0d47a1" name="Score" />
              </BarChart>
            </ResponsiveContainer>
          </Paper>
        </Grid>
      </Grid>

      <Paper sx={{ p: 3, mt: 3 }}>
        <Typography variant="h6" gutterBottom>
          System Health Indicators
        </Typography>
        <Grid container spacing={2} sx={{ mt: 1 }}>
          <Grid item xs={12} sm={6} md={3}>
            <Box sx={{ textAlign: 'center' }}>
              <Typography variant="body2" color="text.secondary">
                Compliance Rate
              </Typography>
              <Typography variant="h4" color="success.main">
                98.5%
              </Typography>
            </Box>
          </Grid>
          <Grid item xs={12} sm={6} md={3}>
            <Box sx={{ textAlign: 'center' }}>
              <Typography variant="body2" color="text.secondary">
                Avg. Branch Performance
              </Typography>
              <Typography variant="h4" color="primary.main">
                87.6%
              </Typography>
            </Box>
          </Grid>
          <Grid item xs={12} sm={6} md={3}>
            <Box sx={{ textAlign: 'center' }}>
              <Typography variant="body2" color="text.secondary">
                System Uptime
              </Typography>
              <Typography variant="h4" color="success.main">
                99.9%
              </Typography>
            </Box>
          </Grid>
          <Grid item xs={12} sm={6} md={3}>
            <Box sx={{ textAlign: 'center' }}>
              <Typography variant="body2" color="text.secondary">
                Active Users
              </Typography>
              <Typography variant="h4" color="info.main">
                1,247
              </Typography>
            </Box>
          </Grid>
        </Grid>
      </Paper>
    </Box>
  )
}

export default OverviewPage
