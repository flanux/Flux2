export const formatCurrency = (amount: number) => new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(amount);
export const formatDate = (date: string) => new Date(date).toLocaleDateString();
export const maskAccountNumber = (num: string) => '**** **** **** ' + num.slice(-4);
