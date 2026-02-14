import api from './api'
import { Transaction } from '../types'

export const transactionService = {
  getAll: async (): Promise<Transaction[]> => {
    const response = await api.get('/transactions')
    return response.data
  },

  getById: async (id: string): Promise<Transaction> => {
    const response = await api.get(`/transactions/${id}`)
    return response.data
  },

  getByAccount: async (accountNumber: string): Promise<Transaction[]> => {
    const response = await api.get(`/transactions/account/${accountNumber}`)
    return response.data
  },

  createDeposit: async (data: Partial<Transaction>): Promise<Transaction> => {
    const response = await api.post('/transactions/deposit', data)
    return response.data
  },

  createWithdrawal: async (data: Partial<Transaction>): Promise<Transaction> => {
    const response = await api.post('/transactions/withdrawal', data)
    return response.data
  },

  createTransfer: async (data: Partial<Transaction>): Promise<Transaction> => {
    const response = await api.post('/transactions/transfer', data)
    return response.data
  },

  getTodayTransactions: async (): Promise<Transaction[]> => {
    const response = await api.get('/transactions/today')
    return response.data
  },
}
