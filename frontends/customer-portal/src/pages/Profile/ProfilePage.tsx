import { Typography, Paper, TextField, Button, Box } from '@mui/material';
import { useAuth } from '../../hooks/useAuth';
export default function ProfilePage() {
  const { user } = useAuth();
  if (!user) return null;
  return (
    <>
      <Typography variant="h4" gutterBottom>My Profile</Typography>
      <Paper sx={{ p: 3, maxWidth: 600 }}>
        <TextField fullWidth label="First Name" value={user.firstName} margin="normal" disabled />
        <TextField fullWidth label="Last Name" value={user.lastName} margin="normal" disabled />
        <TextField fullWidth label="Email" value={user.email} margin="normal" disabled />
        <TextField fullWidth label="Username" value={user.username} margin="normal" disabled />
        <Box sx={{ mt: 3 }}>
          <Button variant="contained">Change Password</Button>
        </Box>
      </Paper>
    </>
  );
}
