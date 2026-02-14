import api from './api'
import { Customer } from '../types'

export const customerService = {
  getAll: async (): Promise<Customer[]> => {
    const response = await api.get('/customers')
    return response.data
  },

  getById: async (id: string): Promise<Customer> => {
    const response = await api.get(`/customers/${id}`)
    return response.data
  },

  create: async (data: Partial<Customer>): Promise<Customer> => {
    const response = await api.post('/customers', data)
    return response.data
  },

  update: async (id: string, data: Partial<Customer>): Promise<Customer> => {
    const response = await api.put(`/customers/${id}`, data)
    return response.data
  },

  delete: async (id: string): Promise<void> => {
    await api.delete(`/customers/${id}`)
  },

  search: async (query: string): Promise<Customer[]> => {
    const response = await api.get(`/customers/search?q=${query}`)
    return response.data
  },
}
