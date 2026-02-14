import { Drawer, List, ListItem, ListItemIcon, ListItemText, Toolbar } from '@mui/material';
import { Dashboard, AccountBalance, SwapHoriz, CreditCard, Payment, Person } from '@mui/icons-material';
import { useNavigate } from 'react-router-dom';
const menuItems = [
  { text: 'Dashboard', icon: <Dashboard />, path: '/' },
  { text: 'Accounts', icon: <AccountBalance />, path: '/accounts' },
  { text: 'Transactions', icon: <SwapHoriz />, path: '/transactions' },
  { text: 'Transfer', icon: <Payment />, path: '/transfer' },
  { text: 'Loans', icon: <CreditCard />, path: '/loans' },
  { text: 'Cards', icon: <CreditCard />, path: '/cards' },
  { text: 'Profile', icon: <Person />, path: '/profile' },
];
export default function Sidebar() {
  const navigate = useNavigate();
  return (
    <Drawer variant="permanent" sx={{ width: 240, [`& .MuiDrawer-paper`]: { width: 240, boxSizing: 'border-box' } }}>
      <Toolbar />
      <List>
        {menuItems.map((item) => (
          <ListItem button key={item.text} onClick={() => navigate(item.path)}>
            <ListItemIcon>{item.icon}</ListItemIcon>
            <ListItemText primary={item.text} />
          </ListItem>
        ))}
      </List>
    </Drawer>
  );
}
