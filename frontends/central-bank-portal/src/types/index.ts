export interface User {
  id: string
  username: string
  name: string
  email: string
  role: string
  permissions: string[]
}

export interface Branch {
  id: string
  branchCode: string
  branchName: string
  location: string
  manager: string
  totalCustomers: number
  totalAccounts: number
  totalDeposits: number
  totalLoans: number
  status: 'active' | 'inactive'
  performance: 'excellent' | 'good' | 'average' | 'poor'
}

export interface SystemStats {
  totalBranches: number
  activeBranches: number
  totalCustomers: number
  totalAccounts: number
  systemDeposits: number
  systemLoans: number
  todayTransactions: number
  systemLiquidity: number
}

export interface ComplianceReport {
  id: string
  branchId: string
  branchName: string
  reportType: string
  status: 'compliant' | 'non-compliant' | 'pending'
  issueDate: string
  dueDate: string
  submittedDate?: string
}

export interface PolicyDocument {
  id: string
  title: string
  category: 'lending' | 'deposit' | 'kyc' | 'aml' | 'general'
  version: string
  effectiveDate: string
  status: 'active' | 'draft' | 'archived'
  lastModified: string
}

export interface InterestRate {
  id: string
  productType: 'savings' | 'checking' | 'fixed_deposit' | 'personal_loan' | 'home_loan' | 'auto_loan'
  rate: number
  effectiveDate: string
  lastModified: string
  modifiedBy: string
}

export interface LiquidityData {
  branchId: string
  branchName: string
  cashOnHand: number
  reserves: number
  liquidity: number
  ratio: number
  status: 'healthy' | 'warning' | 'critical'
}

export interface AuditLog {
  id: string
  timestamp: string
  userId: string
  userName: string
  action: string
  module: string
  details: string
  ipAddress: string
}

export interface BranchPerformance {
  branchId: string
  branchName: string
  metrics: {
    newCustomers: number
    totalTransactions: number
    deposits: number
    withdrawals: number
    loansIssued: number
    revenue: number
  }
  period: string
}

export interface ChartData {
  name: string
  [key: string]: string | number
}
