export interface User {
  id: number;
  username: string;
  email: string;
  firstName: string;
  lastName: string;
  customerId: number;
  role: 'CUSTOMER';
}

export interface LoginRequest {
  username: string;
  password: string;
}

export interface LoginResponse {
  token: string;
  user: User;
}

export interface Account {
  id: number;
  accountNumber: string;
  accountType: 'SAVINGS' | 'CHECKING' | 'FIXED_DEPOSIT';
  balance: number;
  currency: string;
  status: 'ACTIVE' | 'INACTIVE' | 'FROZEN';
}

export interface Transaction {
  id: number;
  transactionId: string;
  amount: number;
  currency: string;
  transactionType: 'DEPOSIT' | 'WITHDRAWAL' | 'TRANSFER';
  transactionStatus: 'COMPLETED' | 'PENDING' | 'FAILED';
  description: string;
  createdAt: string;
}

export interface Loan {
  id: number;
  loanNumber: string;
  loanType: 'PERSONAL' | 'HOME' | 'AUTO';
  principalAmount: number;
  outstandingBalance: number;
  interestRate: number;
  monthlyPayment: number;
  nextPaymentDate: string;
  loanStatus: 'ACTIVE' | 'PAID_OFF';
}

export interface Card {
  id: number;
  lastFourDigits: string;
  cardType: 'DEBIT' | 'CREDIT';
  expiryDate: string;
  status: 'ACTIVE' | 'BLOCKED';
}

export interface ApiResponse<T> {
  success: boolean;
  data: T;
  message?: string;
}
