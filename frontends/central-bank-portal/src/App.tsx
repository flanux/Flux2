import { Routes, Route, Navigate } from 'react-router-dom'
import { Box } from '@mui/material'
import LoginPage from './pages/LoginPage'
import DashboardLayout from './components/DashboardLayout'
import OverviewPage from './pages/OverviewPage'
import BranchesPage from './pages/BranchesPage'
import CompliancePage from './pages/CompliancePage'
import PolicyPage from './pages/PolicyPage'
import RatesPage from './pages/RatesPage'
import LiquidityPage from './pages/LiquidityPage'
import ReportsPage from './pages/ReportsPage'
import AuditPage from './pages/AuditPage'
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
          <Route index element={<Navigate to="/overview" replace />} />
          <Route path="overview" element={<OverviewPage />} />
          <Route path="branches" element={<BranchesPage />} />
          <Route path="compliance" element={<CompliancePage />} />
          <Route path="policy" element={<PolicyPage />} />
          <Route path="rates" element={<RatesPage />} />
          <Route path="liquidity" element={<LiquidityPage />} />
          <Route path="reports" element={<ReportsPage />} />
          <Route path="audit" element={<AuditPage />} />
        </Route>
      </Routes>
    </Box>
  )
}

export default App
