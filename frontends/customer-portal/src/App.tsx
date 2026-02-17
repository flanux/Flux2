import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { useEffect } from 'react';
import { useAuthStore } from './store/authStore';
import authService from './services/authService';
import LoginPage from './pages/Login/LoginPage';
import DashboardPage from './pages/Dashboard/DashboardPage';
import AccountsPage from './pages/Accounts/AccountsPage';
import TransactionsPage from './pages/Transactions/TransactionsPage';
import TransferPage from './pages/Transfer/TransferPage';
import LoansPage from './pages/Loans/LoansPage';
import CardsPage from './pages/Cards/CardsPage';
import ProfilePage from './pages/Profile/ProfilePage';
import MainLayout from './components/layout/MainLayout';

function ProtectedRoute({ children }: { children: React.ReactNode }) {
  const { user } = useAuthStore();
  return user ? <>{children}</> : <Navigate to="/login" />;
}

function App() {
  const { setAuth } = useAuthStore();
  useEffect(() => {
    const user = authService.getCurrentUser();
    const token = localStorage.getItem('authToken');
    if (user && token) setAuth(user, token);
  }, []);
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/login" element={<LoginPage />} />
        <Route path="/" element={<ProtectedRoute><MainLayout /></ProtectedRoute>}>
          <Route index element={<DashboardPage />} />
          <Route path="accounts" element={<AccountsPage />} />
          <Route path="transactions" element={<TransactionsPage />} />
          <Route path="transfer" element={<TransferPage />} />
          <Route path="loans" element={<LoansPage />} />
          <Route path="cards" element={<CardsPage />} />
          <Route path="profile" element={<ProfilePage />} />
        </Route>
      </Routes>
    </BrowserRouter>
  );
}
export default App;
