import api from './api';
import { LoginRequest, LoginResponse } from '../types';

interface BackendLoginResponse {
  accessToken: string;
  refreshToken: string;
  tokenType: string;
  expiresIn: number;
  user: {
    id: number;
    username: string;
    email: string;
    role: string;
    customerId?: number;
    branchId?: number;
  };
}

class AuthService {
  async login(credentials: LoginRequest): Promise<LoginResponse> {
    const { data } = await api.post<BackendLoginResponse>('/auth/login', credentials);
    
    // Map backend response to frontend expected format
    const token = data.accessToken;
    const user = {
      ...data.user,
      firstName: data.user.username,
      lastName: '',
    };
    
    localStorage.setItem('authToken', token);
    localStorage.setItem('userData', JSON.stringify(user));
    
    return { token, user };
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
