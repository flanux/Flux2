import { useEffect, useState } from 'react';
import { Typography, Grid, Card, CardContent, Button } from '@mui/material';
import { Loan } from '../../types';
import loanService from '../../services/loanService';
import LoadingSpinner from '../../components/common/LoadingSpinner';
import { formatCurrency, formatDate } from '../../utils/formatters';
export default function LoansPage() {
  const [loans, setLoans] = useState<Loan[]>([]);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    loadLoans();
  }, []);
  const loadLoans = async () => {
    try {
      const data = await loanService.getMyLoans();
      setLoans(data);
    } finally {
      setLoading(false);
    }
  };
  if (loading) return <LoadingSpinner />;
  return (
    <>
      <Typography variant="h4" gutterBottom>My Loans</Typography>
      <Grid container spacing={3}>
        {loans.map((loan) => (
          <Grid item xs={12} md={6} key={loan.id}>
            <Card>
              <CardContent>
                <Typography variant="h6">{loan.loanType} Loan</Typography>
                <Typography color="text.secondary">{loan.loanNumber}</Typography>
                <Typography>Principal: {formatCurrency(loan.principalAmount)}</Typography>
                <Typography>Outstanding: {formatCurrency(loan.outstandingBalance)}</Typography>
                <Typography>Monthly Payment: {formatCurrency(loan.monthlyPayment)}</Typography>
                <Typography>Next Payment: {formatDate(loan.nextPaymentDate)}</Typography>
                <Typography>Status: {loan.loanStatus}</Typography>
                <Button variant="contained" sx={{ mt: 2 }}>Make Payment</Button>
              </CardContent>
            </Card>
          </Grid>
        ))}
      </Grid>
    </>
  );
}
