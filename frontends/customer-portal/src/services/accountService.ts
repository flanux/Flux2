import api from './api';
import { Account, ApiResponse } from '../types';
class AccountService {
  async getMyAccounts() {
    const { data } = await api.get<ApiResponse<Account[]>>('/accounts/my');
    return data.data;
  }
  async getAccount(id: number) {
    const { data } = await api.get<ApiResponse<Account>>(`/accounts/my/${id}`);
    return data.data;
  }
}
export default new AccountService();
