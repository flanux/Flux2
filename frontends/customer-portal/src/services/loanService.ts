import api from './api';
import { Loan, ApiResponse } from '../types';
class LoanService {
  async getMyLoans() {
    const { data } = await api.get<ApiResponse<Loan[]>>('/loans/my');
    return data.data;
  }
  async applyForLoan(loanData: any) {
    const { data } = await api.post<ApiResponse<any>>('/loans/apply', loanData);
    return data.data;
  }
  async makePayment(loanId: number, amount: number) {
    const { data } = await api.post<ApiResponse<any>>(`/loans/${loanId}/payment`, { amount });
    return data.data;
  }
}
export default new LoanService();
