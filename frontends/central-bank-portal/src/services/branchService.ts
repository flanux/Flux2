import api from './api'
import { Branch, BranchPerformance } from '../types'

export const branchService = {
  getAll: async (): Promise<Branch[]> => {
    const response = await api.get('/central/branches')
    return response.data
  },

  getById: async (id: string): Promise<Branch> => {
    const response = await api.get(`/central/branches/${id}`)
    return response.data
  },

  getPerformance: async (branchId: string, period: string): Promise<BranchPerformance> => {
    const response = await api.get(`/central/branches/${branchId}/performance?period=${period}`)
    return response.data
  },

  getAllPerformance: async (period: string): Promise<BranchPerformance[]> => {
    const response = await api.get(`/central/branches/performance?period=${period}`)
    return response.data
  },
}
