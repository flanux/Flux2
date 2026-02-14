# FLUX
## Distributed Banking Infrastructure

> *Where money flows, systems scale, and failures dissolve.*

A production-grade microservices banking platform designed for **liquidity**, **resilience**, and **scale**.

---

## 🌊 What is FLUX?

**FLUX** is a distributed core banking system that treats financial transactions as **flow** - continuous, unstoppable, and failure-proof. Built on microservices architecture, FLUX ensures that money moves through the system like water through channels, with zero single points of failure.

In physics and finance, **flux** represents the rate of flow through a system. FLUX embodies this principle through:
- 8 independent microservices (the channels)
- 3-tier access control (Central Bank → Branch → Customer)  
- Event-driven architecture (Kafka streams)
- Unidirectional data flow (predictable, debuggable)

---

## ⚡ Quick Start

### Option 1: Fast Deployment (30 seconds) - Recommended
Uses pre-built Docker images from GitHub Container Registry:

```bash
# 1. Set your GitHub username in .env
echo "GITHUB_USER=flanux" >> .env

# 2. Deploy with published images
docker-compose -f docker-compose.prod.yml up -d

# 3. Access portals (wait ~1 minute for startup)
open http://localhost:3000  # Customer
open http://localhost:3001  # Branch  
open http://localhost:3002  # Central Bank
```

### Option 2: Development Build (5-10 minutes)
Builds everything from source for development:

```bash
# 1. Build and start
./flux-start.sh

# 2. Access portals
open http://localhost:3000  # Customer
open http://localhost:3001  # Branch  
open http://localhost:3002  # Central Bank

# 3. Generate demo data
./flux-playground.sh
```

### Option 3: Smart Auto-Detect
Automatically chooses the fastest method:

```bash
./flux-start-smart.sh  # Detects and uses best option
```

**That's it.** No manual configuration needed.

---

## 🏗️ Architecture

### The Flow

```
Central Bank (3002) ─────┐
                         │
Branch Dashboards (3001) ├──► API Gateway (8089)
                         │           │
Customer Portals (3000) ─┘           │
                                     │
                    ┌────────────────┴────────────────┐
                    │                                 │
        ┌───────────▼──────────┐         ┌───────────▼──────────┐
        │   Core Services      │         │  Support Services    │
        │  • Account   (8081)  │         │  • Ledger    (8084)  │
        │  • Customer  (8082)  │         │  • Reporting (8086)  │
        │  • Card      (8083)  │         │  • Notify    (8085)  │
        │  • Loan      (8087)  │         │                      │
        │  • Transaction(8088) │         │                      │
        └──────────┬───────────┘         └──────────┬───────────┘
                   │                                │
                   └────────────┬───────────────────┘
                                │
                    ┌───────────▼──────────┐
                    │   PostgreSQL (5432)  │
                    │   8 isolated DBs     │
                    └──────────────────────┘
                                
                    ┌──────────────────────┐
                    │  Kafka + Zookeeper   │
                    │    Event Streams     │
                    └──────────────────────┘
```

---

## 📦 Components

| Type | Component | Port | Purpose |
|------|-----------|------|---------|
| **Portal** | Customer Portal | 3000 | End-user banking |
| **Portal** | Branch Dashboard | 3001 | Branch operations |
| **Portal** | Central Bank Portal | 3002 | System oversight |
| **Gateway** | API Gateway | 8089 | Single entry point |
| **Service** | Account | 8081 | Account management |
| **Service** | Customer | 8082 | Customer data |
| **Service** | Card | 8083 | Card operations |
| **Service** | Ledger | 8084 | Double-entry ledger |
| **Service** | Notification | 8085 | Alerts & messages |
| **Service** | Reporting | 8086 | Analytics |
| **Service** | Loan | 8087 | Loan processing |
| **Service** | Transaction | 8088 | Payments |
| **Database** | PostgreSQL | 5432 | Data persistence |
| **Message** | Kafka | 9092 | Event streaming |

---

## 🎯 Key Features

### Distributed Architecture
- **No single point of failure** - Services operate independently
- **Horizontal scaling** - Add capacity service-by-service
- **Isolated failures** - One service down ≠ system down

### Event-Driven
- **Kafka streams** - Async communication
- **Real-time updates** - Instant balance refresh
- **Audit trails** - Every event logged

### Production-Ready
- **Docker-first** - Consistent environments
- **Health checks** - Auto-recovery
- **API Gateway** - Load balancing & routing
- **Separate databases** - Data isolation

---

## 🛠️ Tech Stack

**Backend**: Java 17, Spring Boot 3, Kafka, PostgreSQL  
**Frontend**: TypeScript, React 18, Vite, Material-UI  
**DevOps**: Docker, Docker Compose, Nginx

---

## 🚀 Deployment & Publishing

### Production Deployment (Fast)

FLUX supports pre-built Docker images for instant deployment:

```bash
# 1. Set your GitHub username in .env
echo "GITHUB_USER=your-username" >> .env

# 2. Deploy with pre-built images
docker-compose -f docker-compose.prod.yml up -d

# ⚡ Startup: ~30 seconds
```

### Development Mode

Build from source for active development:

```bash
# Use regular docker-compose
docker-compose up -d

# ⚡ First build: ~5-10 minutes
# ⚡ Subsequent: ~2 minutes (cached)
```

### Publishing Your Own Images

Create your own release with automatic image publishing:

```bash
# 1. Create a release
./publish-release.sh v1.0.0 "First stable release"

# 2. GitHub Actions automatically:
#    ✅ Builds all 12 Docker images
#    ✅ Publishes to GitHub Container Registry
#    ✅ Tags with semantic versioning

# 3. Your team can deploy in 30 seconds!
```

**Benefits:**
- ⚡ 30-second deployments vs 10 minutes
- 🔄 Version control for all services
- 📦 Easy rollbacks
- 👥 Team consistency

See [DOCKER_PUBLISHING_GUIDE.md](./DOCKER_PUBLISHING_GUIDE.md) for complete guide.

---

## 📊 Demo Mode

Generate realistic data for demos/testing:

```bash
./flux-playground.sh
```

Options:
1. Full demo (10 customers, 5 accounts, 20 transactions)
2. Custom scenarios
3. View current data
4. Reset database

---

## 🔒 Security

- JWT authentication
- Role-based access control (RBAC)
- Encrypted transport (TLS)
- Audit logging
- No hardcoded secrets

---

## 📈 Scaling

```bash
# Scale individual services
docker compose up -d --scale account-service=3
docker compose up -d --scale transaction-service=5

# Add database replicas (production)
# Add cache layer (Redis)
# Deploy to Kubernetes
```

---

## 📝 Project Structure

```
flux/
├── services/              # 8 microservices
├── frontends/             # 3 portals
├── bank-api-gateway/      # Gateway
├── database/              # DB scripts
├── message-broker/        # Kafka configs
├── docker-compose.yml     # Orchestration
├── flux-start.sh          # Startup
└── flux-playground.sh     # Demo data
```

---

## 🚀 Commands

```bash
# === Quick Start ===
./flux-start-smart.sh          # Smart auto-detect mode
./flux-start.sh                # Development build
docker-compose -f docker-compose.prod.yml up -d  # Production images

# === Release Management ===
./publish-release.sh v1.0.0 "Release message"  # Publish new release

# === Development ===
docker compose ps              # Check status
docker compose logs -f         # View logs
docker compose logs -f account-service  # Service logs
./health-check.sh              # Health check

# === Data Management ===
./flux-playground.sh           # Generate demo data
docker compose down -v         # Reset all data

# === Cleanup ===
docker compose down            # Stop services
docker system prune -a         # Clean up Docker
```

---

## 🎓 Use Cases

**Central Bank** - System monitoring, policy management, compliance  
**Branches** - Customer onboarding, loans, transactions  
**Customers** - Banking operations, transfers, account management

---

## 📄 Documentation

- `QUICKSTART.md` - 5-minute setup guide
- `DEPLOYMENT_GUIDE.md` - Production deployment
- `SCRIPTS_GUIDE.md` - All commands explained
- Service-specific READMEs in each `/services` directory

---

## 🔄 Roadmap

**Current**: Core banking microservices, 3 portals, Docker deployment  
**Next**: Kubernetes, CI/CD, monitoring (Prometheus/Grafana)  
**Future**: Multi-tenancy, mobile apps, AI fraud detection

---

**FLUX** - Distributed banking infrastructure for the modern era.

Built with Spring Boot, React, and a relentless focus on **flow**.
