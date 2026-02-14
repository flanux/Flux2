import { useAuthStore } from '../store/authStore';
import authService from '../services/authService';
export const useAuth = () => {
  const { user, setAuth, clearAuth } = useAuthStore();
  const login = async (username: string, password: string) => {
    const response = await authService.login({ username, password });
    setAuth(response.user, response.token);
  };
  const logout = async () => {
    await authService.logout();
    clearAuth();
  };
  return { user, login, logout, isAuthenticated: !!user };
};
