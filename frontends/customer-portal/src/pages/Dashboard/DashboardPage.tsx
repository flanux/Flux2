import { useEffect, useState } from 'react';
import { Grid, Typography, Card, CardContent } from '@mui/material';
import { Account } from '../../types';
import accountService from '../../services/accountService';
import LoadingSpinner from '../../components/common/LoadingSpinner';
import AccountCard from '../../components/features/AccountCard';
export default function DashboardPage() {
  const [accounts, setAccounts] = useState<Account[]>([]);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    loadAccounts();
  }, []);
  const loadAccounts = async () => {
    try {
      const data = await accountService.getMyAccounts();
      setAccounts(data);
    } finally {
      setLoading(false);
    }
  };
  if (loading) return <LoadingSpinner />;
  const totalBalance = accounts.reduce((sum, acc) => sum + acc.balance, 0);
  return (
    <>
      <Typography variant="h4" gutterBottom>Dashboard</Typography>
      <Grid container spacing={3}>
        <Grid item xs={12}>
          <Card>
            <CardContent>
              <Typography color="text.secondary">Total Balance</Typography>
              <Typography variant="h3">${totalBalance.toFixed(2)}</Typography>
            </CardContent>
          </Card>
        </Grid>
        {accounts.map((account) => (
          <Grid item xs={12} md={6} key={account.id}>
            <AccountCard account={account} />
          </Grid>
        ))}
      </Grid>
    </>
  );
}
