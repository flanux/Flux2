import api from './api';
import { Card, ApiResponse } from '../types';
class CardService {
  async getMyCards() {
    const { data } = await api.get<ApiResponse<Card[]>>('/cards/my');
    return data.data;
  }
  async blockCard(cardId: number, reason: string) {
    const { data } = await api.post<ApiResponse<any>>(`/cards/${cardId}/block`, { reason });
    return data.data;
  }
}
export default new CardService();
