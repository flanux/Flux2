import { useEffect, useState } from 'react';
import { Typography, Grid } from '@mui/material';
import { Account } from '../../types';
import accountService from '../../services/accountService';
import LoadingSpinner from '../../components/common/LoadingSpinner';
import AccountCard from '../../components/features/AccountCard';
export default function AccountsPage() {
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
  return (
    <>
      <Typography variant="h4" gutterBottom>My Accounts</Typography>
      <Grid container spacing={3}>
        {accounts.map((account) => (
          <Grid item xs={12} md={6} key={account.id}>
            <AccountCard account={account} />
          </Grid>
        ))}
      </Grid>
    </>
  );
}
