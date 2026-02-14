import { useEffect, useState } from 'react';
import { Typography, Grid, Card, CardContent, Button, Chip } from '@mui/material';
import { Card as CardType } from '../../types';
import cardService from '../../services/cardService';
import LoadingSpinner from '../../components/common/LoadingSpinner';
import { toast } from 'react-toastify';
export default function CardsPage() {
  const [cards, setCards] = useState<CardType[]>([]);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    loadCards();
  }, []);
  const loadCards = async () => {
    try {
      const data = await cardService.getMyCards();
      setCards(data);
    } finally {
      setLoading(false);
    }
  };
  const handleBlock = async (cardId: number) => {
    try {
      await cardService.blockCard(cardId, 'Customer requested');
      toast.success('Card blocked successfully');
      loadCards();
    } catch (error) {
      toast.error('Failed to block card');
    }
  };
  if (loading) return <LoadingSpinner />;
  return (
    <>
      <Typography variant="h4" gutterBottom>My Cards</Typography>
      <Grid container spacing={3}>
        {cards.map((card) => (
          <Grid item xs={12} md={6} key={card.id}>
            <Card>
              <CardContent>
                <Typography variant="h6">{card.cardType} Card</Typography>
                <Typography variant="h4">**** **** **** {card.lastFourDigits}</Typography>
                <Typography>Expires: {card.expiryDate}</Typography>
                <Chip label={card.status} color={card.status === 'ACTIVE' ? 'success' : 'error'} size="small" sx={{ mt: 1 }} />
                {card.status === 'ACTIVE' && (
                  <Button variant="outlined" color="error" sx={{ mt: 2 }} onClick={() => handleBlock(card.id)}>
                    Block Card
                  </Button>
                )}
              </CardContent>
            </Card>
          </Grid>
        ))}
      </Grid>
    </>
  );
}
