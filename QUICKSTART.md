# Quick Start Guide

Get the complete banking system up and running in 5 minutes!

## ⚡ Super Quick Start

```bash
# 1. Extract the project
unzip complete-banking-system.zip
cd complete-banking-system

# 2. Start everything
./start.sh

# 3. Wait 2-3 minutes, then access:
# Customer Portal: http://localhost:3000
# Branch Dashboard: http://localhost:3001
# Central Bank: http://localhost:3002
```

## 📋 Prerequisites

### Required
- Docker Desktop (or Docker Engine + Docker Compose)
- 16GB RAM minimum
- 20GB free disk space

### Ports Needed
Make sure these ports are free:
- **3000-3002** - Frontends
- **5432** - PostgreSQL
- **8081-8089** - Backend services
- **9092** - Kafka
- **2181** - Zookeeper

### Check Ports
```bash
# macOS/Linux
lsof -i :3000

# Windows
netstat -ano | findstr :3000
```

## 🚀 Step-by-Step

### Step 1: Start Infrastructure

```bash
docker-compose up -d database zookeeper kafka
```

Wait 10-15 seconds for database and Kafka to initialize.

### Step 2: Start Backend Services

```bash
docker-compose up -d \
  account-service \
  customer-service \
  card-service \
  ledger-service \
  loan-service \
  notification-service \
  reporting-service \
  transaction-service \
  bank-api-gateway
```

Wait 30-60 seconds for services to start.

### Step 3: Start Frontends

```bash
docker-compose up -d \
  customer-portal \
  branch-dashboard \
  central-bank-portal
```

Wait 20-30 seconds for frontends to build.

### Step 4: Verify

```bash
# Check all services are running
docker-compose ps

# Run health check
./health-check.sh
```

## 🌐 Access Applications

| App | URL | Login |
|-----|-----|-------|
| **Customer Portal** | http://localhost:3000 | Any username/password |
| **Branch Dashboard** | http://localhost:3001 | Any + branch code |
| **Central Bank** | http://localhost:3002 | Any username/password |

## 🔍 Troubleshooting

### Services not starting?

```bash
# View logs
docker-compose logs -f

# Rebuild a service
docker-compose build --no-cache account-service
docker-compose up -d account-service
```

### Port already in use?

```bash
# Find what's using the port
lsof -i :8081  # Replace with your port

# Stop it, or change the port in docker-compose.yml
```

### Database not ready?

```bash
# Check database
docker-compose logs database

# Restart database
docker-compose restart database
```

### Frontend shows blank page?

```bash
# Check browser console (F12)
# Verify API Gateway is running
curl http://localhost:8089/actuator/health

# Rebuild frontend
docker-compose build customer-portal
docker-compose up -d customer-portal
```

## 🛑 Stopping

```bash
# Stop all services
docker-compose down

# Stop and remove data (fresh start)
docker-compose down -v
```

## 📊 Monitoring

### View Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f account-service

# Last 100 lines
docker-compose logs --tail=100 -f
```

### Check Service Health

```bash
# Individual service
curl http://localhost:8081/actuator/health

# All services
./health-check.sh
```

### Docker Stats

```bash
# Resource usage
docker stats

# Container list
docker ps
```

## 🎯 What to Try First

### 1. Customer Portal (3000)
- Create an account
- View transactions
- Make a transfer

### 2. Branch Dashboard (3001)
- Add a customer
- Open an account
- Process a transaction
- Issue a card

### 3. Central Bank Portal (3002)
- View system overview
- Check branch performance
- Review compliance stats

## 💡 Tips

1. **First startup takes longer** - Docker needs to build images (5-10 minutes)
2. **Subsequent starts are faster** - Images are cached (~1 minute)
3. **Services start in order** - Database → Services → Gateway → Frontends
4. **Check logs if issues** - `docker-compose logs -f [service]`
5. **Fresh start if broken** - `docker-compose down -v && ./start.sh`

## 🔧 Common Issues

### "Port already allocated"
- Another service is using the port
- Stop it or change port in `docker-compose.yml`

### "Connection refused"
- Service hasn't started yet - wait 30 seconds
- Check logs: `docker-compose logs [service]`

### "Out of memory"
- Docker needs more RAM
- Increase in Docker Desktop settings
- Or reduce services running

### "Build failed"
- Network issue downloading dependencies
- Run: `docker-compose build --no-cache [service]`

## 📚 Next Steps

1. ✅ Get system running
2. ✅ Explore all 3 portals
3. 🔲 Connect to real authentication
4. 🔲 Customize business logic
5. 🔲 Add monitoring (Prometheus/Grafana)
6. 🔲 Set up CI/CD
7. 🔲 Deploy to production

## 🆘 Getting Help

1. Check logs: `docker-compose logs -f`
2. Run health check: `./health-check.sh`
3. Check README.md for detailed docs
4. Restart specific service: `docker-compose restart [service]`
5. Full reset: `docker-compose down -v && ./start.sh`

---

**Ready to go?** Run `./start.sh` and you're live in 2 minutes! 🚀
