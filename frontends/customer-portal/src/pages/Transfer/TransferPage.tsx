import { useState, useEffect } from 'react';
import { Typography, Paper, TextField, Button, MenuItem, Box } from '@mui/material';
import { Account } from '../../types';
import accountService from '../../services/accountService';
import transactionService from '../../services/transactionService';
import { toast } from 'react-toastify';
export default function TransferPage() {
  const [accounts, setAccounts] = useState<Account[]>([]);
  const [fromAccount, setFromAccount] = useState<number | ''>('');
  const [toAccount, setToAccount] = useState('');
  const [amount, setAmount] = useState('');
  const [description, setDescription] = useState('');
  const [loading, setLoading] = useState(false);
  useEffect(() => {
    loadAccounts();
  }, []);
  const loadAccounts = async () => {
    const data = await accountService.getMyAccounts();
    setAccounts(data);
  };
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    try {
      await transactionService.transfer(fromAccount as number, toAccount, Number(amount), description);
      toast.success('Transfer successful');
      setToAccount('');
      setAmount('');
      setDescription('');
    } catch (error) {
      toast.error('Transfer failed');
    } finally {
      setLoading(false);
    }
  };
  return (
    <>
      <Typography variant="h4" gutterBottom>Transfer Money</Typography>
      <Paper sx={{ p: 3, maxWidth: 600 }}>
        <form onSubmit={handleSubmit}>
          <TextField select fullWidth label="From Account" value={fromAccount} onChange={(e) => setFromAccount(Number(e.target.value))} margin="normal" required>
            {accounts.map((acc) => (
              <MenuItem key={acc.id} value={acc.id}>{acc.accountType} - ${acc.balance.toFixed(2)}</MenuItem>
            ))}
          </TextField>
          <TextField fullWidth label="To Account Number" value={toAccount} onChange={(e) => setToAccount(e.target.value)} margin="normal" required />
          <TextField fullWidth label="Amount" type="number" value={amount} onChange={(e) => setAmount(e.target.value)} margin="normal" required />
          <TextField fullWidth label="Description" value={description} onChange={(e) => setDescription(e.target.value)} margin="normal" />
          <Box sx={{ mt: 3 }}>
            <Button type="submit" variant="contained" size="large" fullWidth disabled={loading}>
              {loading ? 'Processing...' : 'Transfer'}
            </Button>
          </Box>
        </form>
      </Paper>
    </>
  );
}
