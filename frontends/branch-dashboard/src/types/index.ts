export interface User {
  id: string
  username: string
  name: string
  email: string
  role: string
  branchCode: string
  branchName: string
}

export interface Customer {
  id: string
  firstName: string
  lastName: string
  email: string
  phone: string
  address?: string
  dateOfBirth?: string
  idNumber?: string
  status: 'active' | 'inactive'
  createdAt: string
}

export interface Account {
  id: string
  accountNumber: string
  customerId: string
  customerName: string
  type: 'SAVINGS' | 'CHECKING' | 'FIXED_DEPOSIT'
  balance: number
  status: 'active' | 'closed' | 'frozen'
  createdAt: string
}

export interface Transaction {
  id: string
  type: 'DEPOSIT' | 'WITHDRAWAL' | 'TRANSFER'
  accountNumber: string
  toAccountNumber?: string
  amount: number
  description?: string
  status: 'pending' | 'completed' | 'failed'
  createdAt: string
}

export interface Card {
  id: string
  cardNumber: string
  customerId: string
  customerName: string
  type: 'DEBIT' | 'CREDIT'
  status: 'active' | 'blocked' | 'expired'
  expiryDate: string
  creditLimit?: number
  createdAt: string
}

export interface Loan {
  id: string
  customerId: string
  customerName: string
  type: 'PERSONAL' | 'HOME' | 'AUTO' | 'EDUCATION'
  amount: number
  tenure: number
  interestRate: number
  status: 'pending' | 'approved' | 'active' | 'rejected' | 'paid'
  appliedDate: string
  approvedDate?: string
}

export interface DashboardStats {
  todayTransactions: number
  todayDeposits: number
  todayWithdrawals: number
  totalCustomers: number
  activeAccounts: number
  pendingLoans: number
}

export interface ChartData {
  name: string
  [key: string]: string | number
}
