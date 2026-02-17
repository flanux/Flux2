import { useEffect, useState } from 'react';
import { Typography, Table, TableBody, TableCell, TableContainer, TableHead, TableRow, Paper, TextField, MenuItem } from '@mui/material';
import { Transaction, Account } from '../../types';
import transactionService from '../../services/transactionService';
import accountService from '../../services/accountService';
import LoadingSpinner from '../../components/common/LoadingSpinner';
import { formatCurrency, formatDate } from '../../utils/formatters';
export default function TransactionsPage() {
  const [transactions, setTransactions] = useState<Transaction[]>([]);
  const [accounts, setAccounts] = useState<Account[]>([]);
  const [selectedAccount, setSelectedAccount] = useState<number | ''>('');
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    loadAccounts();
  }, []);
  useEffect(() => {
    if (selectedAccount) loadTransactions(selectedAccount as number);
  }, [selectedAccount]);
  const loadAccounts = async () => {
    const data = await accountService.getMyAccounts();
    setAccounts(data);
    if (data.length > 0) setSelectedAccount(data[0].id);
    setLoading(false);
  };
  const loadTransactions = async (accountId: number) => {
    const data = await transactionService.getTransactions(accountId);
    setTransactions(data);
  };
  if (loading) return <LoadingSpinner />;
  return (
    <>
      <Typography variant="h4" gutterBottom>Transactions</Typography>
      <TextField select label="Account" value={selectedAccount} onChange={(e) => setSelectedAccount(Number(e.target.value))} sx={{ mb: 3, minWidth: 300 }}>
        {accounts.map((acc) => (
          <MenuItem key={acc.id} value={acc.id}>{acc.accountType} - {acc.accountNumber.slice(-4)}</MenuItem>
        ))}
      </TextField>
      <TableContainer component={Paper}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>Date</TableCell>
              <TableCell>Description</TableCell>
              <TableCell>Type</TableCell>
              <TableCell align="right">Amount</TableCell>
              <TableCell>Status</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {transactions.map((txn) => (
              <TableRow key={txn.id}>
                <TableCell>{formatDate(txn.createdAt)}</TableCell>
                <TableCell>{txn.description}</TableCell>
                <TableCell>{txn.transactionType}</TableCell>
                <TableCell align="right">{formatCurrency(txn.amount)}</TableCell>
                <TableCell>{txn.transactionStatus}</TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </TableContainer>
    </>
  );
}
