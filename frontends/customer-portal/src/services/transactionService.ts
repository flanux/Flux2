import api from './api';
import { Transaction, ApiResponse } from '../types';
class TransactionService {
  async getTransactions(accountId: number) {
    const { data } = await api.get<ApiResponse<Transaction[]>>(`/transactions/my/${accountId}`);
    return data.data;
  }
  async transfer(fromAccountId: number, toAccountNumber: string, amount: number, description: string) {
    const { data } = await api.post<ApiResponse<Transaction>>('/transfers/external', {
      fromAccountId,
      toAccountNumber,
      amount,
      description,
    });
    return data.data;
  }
}
export default new TransactionService();
