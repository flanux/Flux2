import { Routes, Route, Navigate } from 'react-router-dom'
import { Box } from '@mui/material'
import LoginPage from './pages/LoginPage'
import DashboardLayout from './components/DashboardLayout'
import DashboardPage from './pages/DashboardPage'
import CustomersPage from './pages/CustomersPage'
import AccountsPage from './pages/AccountsPage'
import TransactionsPage from './pages/TransactionsPage'
import CardsPage from './pages/CardsPage'
import LoansPage from './pages/LoansPage'
import ReportsPage from './pages/ReportsPage'
import PrivateRoute from './components/PrivateRoute'

function App() {
  return (
    <Box sx={{ display: 'flex' }}>
      <Routes>
        <Route path="/login" element={<LoginPage />} />
        <Route
          path="/"
          element={
            <PrivateRoute>
              <DashboardLayout />
            </PrivateRoute>
          }
        >
          <Route index element={<Navigate to="/dashboard" replace />} />
          <Route path="dashboard" element={<DashboardPage />} />
          <Route path="customers" element={<CustomersPage />} />
          <Route path="accounts" element={<AccountsPage />} />
          <Route path="transactions" element={<TransactionsPage />} />
          <Route path="cards" element={<CardsPage />} />
          <Route path="loans" element={<LoansPage />} />
          <Route path="reports" element={<ReportsPage />} />
        </Route>
      </Routes>
    </Box>
  )
}

export default App
