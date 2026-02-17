import { Card, CardContent, Typography, Chip } from '@mui/material';
import { Account } from '../../types';
import { formatCurrency, maskAccountNumber } from '../../utils/formatters';
export default function AccountCard({ account }: { account: Account }) {
  return (
    <Card>
      <CardContent>
        <Typography variant="h6">{account.accountType}</Typography>
        <Typography color="text.secondary">{maskAccountNumber(account.accountNumber)}</Typography>
        <Typography variant="h4">{formatCurrency(account.balance)}</Typography>
        <Chip label={account.status} color={account.status === 'ACTIVE' ? 'success' : 'default'} size="small" />
      </CardContent>
    </Card>
  );
}
