import api from './api'
import { Account } from '../types'

export const accountService = {
  getAll: async (): Promise<Account[]> => {
    const response = await api.get('/accounts')
    return response.data
  },

  getById: async (id: string): Promise<Account> => {
    const response = await api.get(`/accounts/${id}`)
    return response.data
  },

  getByCustomer: async (customerId: string): Promise<Account[]> => {
    const response = await api.get(`/accounts/customer/${customerId}`)
    return response.data
  },

  create: async (data: Partial<Account>): Promise<Account> => {
    const response = await api.post('/accounts', data)
    return response.data
  },

  close: async (id: string): Promise<void> => {
    await api.put(`/accounts/${id}/close`)
  },
}
