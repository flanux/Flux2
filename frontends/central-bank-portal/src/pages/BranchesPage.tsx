import { useEffect, useState } from 'react'
import {
  Box,
  Paper,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Chip,
  TextField,
  InputAdornment,
  CircularProgress,
  Grid,
  Card,
  CardContent,
  Typography,
} from '@mui/material'
import { Search as SearchIcon } from '@mui/icons-material'
import { Branch } from '../types'

const BranchesPage = () => {
  const [branches, setBranches] = useState<Branch[]>([])
  const [loading, setLoading] = useState(true)
  const [searchTerm, setSearchTerm] = useState('')

  useEffect(() => {
    fetchBranches()
  }, [])

  const fetchBranches = async () => {
    try {
      // TODO: Replace with actual API call
      await new Promise((resolve) => setTimeout(resolve, 1000))
      
      setBranches([
        {
          id: '1',
          branchCode: 'BR001',
          branchName: 'Main Branch',
          location: 'New York, NY',
          manager: 'John Smith',
          totalCustomers: 5432,
          totalAccounts: 7821,
          totalDeposits: 45000000,
          totalLoans: 32000000,
          status: 'active',
          performance: 'excellent',
        },
        {
          id: '2',
          branchCode: 'BR002',
          branchName: 'Downtown Branch',
          location: 'Los Angeles, CA',
          manager: 'Sarah Johnson',
          totalCustomers: 4123,
          totalAccounts: 5892,
          totalDeposits: 38000000,
          totalLoans: 27000000,
          status: 'active',
          performance: 'good',
        },
        {
          id: '3',
          branchCode: 'BR003',
          branchName: 'Suburban Branch',
          location: 'Chicago, IL',
          manager: 'Michael Brown',
          totalCustomers: 3567,
          totalAccounts: 4921,
          totalDeposits: 32000000,
          totalLoans: 23000000,
          status: 'active',
          performance: 'good',
        },
        {
          id: '4',
          branchCode: 'BR004',
          branchName: 'East Side Branch',
          location: 'Houston, TX',
          manager: 'Emily Davis',
          totalCustomers: 2890,
          totalAccounts: 3654,
          totalDeposits: 28000000,
          totalLoans: 19000000,
          status: 'active',
          performance: 'average',
        },
      ])
    } catch (error) {
      console.error('Error fetching branches:', error)
    } finally {
      setLoading(false)
    }
  }

  const filteredBranches = branches.filter(
    (branch) =>
      branch.branchName.toLowerCase().includes(searchTerm.toLowerCase()) ||
      branch.branchCode.toLowerCase().includes(searchTerm.toLowerCase()) ||
      branch.location.toLowerCase().includes(searchTerm.toLowerCase())
  )

  const getPerformanceColor = (performance: string) => {
    switch (performance) {
      case 'excellent':
        return 'success'
      case 'good':
        return 'primary'
      case 'average':
        return 'warning'
      case 'poor':
        return 'error'
      default:
        return 'default'
    }
  }

  const totalStats = {
    customers: branches.reduce((sum, b) => sum + b.totalCustomers, 0),
    accounts: branches.reduce((sum, b) => sum + b.totalAccounts, 0),
    deposits: branches.reduce((sum, b) => sum + b.totalDeposits, 0),
    loans: branches.reduce((sum, b) => sum + b.totalLoans, 0),
  }

  if (loading) {
    return (
      <Box display="flex" justifyContent="center" alignItems="center" minHeight="400px">
        <CircularProgress />
      </Box>
    )
  }

  return (
    <Box>
      <Grid container spacing={3} sx={{ mb: 3 }}>
        <Grid item xs={12} sm={6} md={3}>
          <Card>
            <CardContent>
              <Typography color="text.secondary" variant="body2">
                Total Branches
              </Typography>
              <Typography variant="h4">{branches.length}</Typography>
            </CardContent>
          </Card>
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <Card>
            <CardContent>
              <Typography color="text.secondary" variant="body2">
                Total Customers
              </Typography>
              <Typography variant="h4">{totalStats.customers.toLocaleString()}</Typography>
            </CardContent>
          </Card>
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <Card>
            <CardContent>
              <Typography color="text.secondary" variant="body2">
                Total Deposits
              </Typography>
              <Typography variant="h4">${(totalStats.deposits / 1000000).toFixed(1)}M</Typography>
            </CardContent>
          </Card>
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <Card>
            <CardContent>
              <Typography color="text.secondary" variant="body2">
                Total Loans
              </Typography>
              <Typography variant="h4">${(totalStats.loans / 1000000).toFixed(1)}M</Typography>
            </CardContent>
          </Card>
        </Grid>
      </Grid>

      <Box sx={{ mb: 3 }}>
        <TextField
          placeholder="Search branches..."
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          InputProps={{
            startAdornment: (
              <InputAdornment position="start">
                <SearchIcon />
              </InputAdornment>
            ),
          }}
          sx={{ width: 300 }}
        />
      </Box>

      <TableContainer component={Paper}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>Branch Code</TableCell>
              <TableCell>Branch Name</TableCell>
              <TableCell>Location</TableCell>
              <TableCell>Manager</TableCell>
              <TableCell align="right">Customers</TableCell>
              <TableCell align="right">Accounts</TableCell>
              <TableCell align="right">Deposits</TableCell>
              <TableCell align="right">Loans</TableCell>
              <TableCell>Performance</TableCell>
              <TableCell>Status</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {filteredBranches.map((branch) => (
              <TableRow key={branch.id}>
                <TableCell>{branch.branchCode}</TableCell>
                <TableCell>{branch.branchName}</TableCell>
                <TableCell>{branch.location}</TableCell>
                <TableCell>{branch.manager}</TableCell>
                <TableCell align="right">{branch.totalCustomers.toLocaleString()}</TableCell>
                <TableCell align="right">{branch.totalAccounts.toLocaleString()}</TableCell>
                <TableCell align="right">${(branch.totalDeposits / 1000000).toFixed(1)}M</TableCell>
                <TableCell align="right">${(branch.totalLoans / 1000000).toFixed(1)}M</TableCell>
                <TableCell>
                  <Chip
                    label={branch.performance}
                    color={getPerformanceColor(branch.performance) as any}
                    size="small"
                  />
                </TableCell>
                <TableCell>
                  <Chip
                    label={branch.status}
                    color={branch.status === 'active' ? 'success' : 'default'}
                    size="small"
                  />
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </TableContainer>
    </Box>
  )
}

export default BranchesPage
