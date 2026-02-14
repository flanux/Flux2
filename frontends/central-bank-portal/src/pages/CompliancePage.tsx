import { Box, Typography, Paper, Grid, Chip } from '@mui/material'
import { CheckCircle, Warning, Schedule } from '@mui/icons-material'

const CompliancePage = () => {
  return (
    <Box>
      <Typography variant="h4" gutterBottom>Regulatory Compliance</Typography>
      <Grid container spacing={3} sx={{ mt: 1 }}>
        <Grid item xs={12} md={4}>
          <Paper sx={{ p: 3, textAlign: 'center' }}>
            <CheckCircle sx={{ fontSize: 48, color: 'success.main' }} />
            <Typography variant="h3" sx={{ mt: 2 }}>92%</Typography>
            <Typography color="text.secondary">Compliant</Typography>
          </Paper>
        </Grid>
        <Grid item xs={12} md={4}>
          <Paper sx={{ p: 3, textAlign: 'center' }}>
            <Warning sx={{ fontSize: 48, color: 'warning.main' }} />
            <Typography variant="h3" sx={{ mt: 2 }}>5%</Typography>
            <Typography color="text.secondary">Non-Compliant</Typography>
          </Paper>
        </Grid>
        <Grid item xs={12} md={4}>
          <Paper sx={{ p: 3, textAlign: 'center' }}>
            <Schedule sx={{ fontSize: 48, color: 'info.main' }} />
            <Typography variant="h3" sx={{ mt: 2 }}>3%</Typography>
            <Typography color="text.secondary">Pending Review</Typography>
          </Paper>
        </Grid>
      </Grid>
      <Typography variant="body1" sx={{ mt: 4 }}>
        Full compliance tracking and reporting coming soon...
      </Typography>
    </Box>
  )
}

export default CompliancePage
