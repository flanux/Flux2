import api from './api';
import { LoginRequest, LoginResponse, ApiResponse } from '../types';
class AuthService {
  async login(credentials: LoginRequest) {
    const { data } = await api.post<ApiResponse<LoginResponse>>('/auth/login', credentials);
    if (data.success && data.data.token) {
      localStorage.setItem('authToken', data.data.token);
      localStorage.setItem('userData', JSON.stringify(data.data.user));
    }
    return data.data;
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
