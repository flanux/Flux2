# 🚀 Scripts Guide - Banking System

Complete guide to all available scripts for easy setup, development, and testing.

## 📂 Available Scripts

### 🎯 One-Click Startup (For Your Friends)

These scripts do EVERYTHING automatically - no technical knowledge needed!

| Script | Platform | What It Does |
|--------|----------|--------------|
| `START-WINDOWS.bat` | Windows | Double-click to start entire system |
| `START-MAC.sh` | macOS | Double-click to start entire system |
| `START-LINUX.sh` | Linux | Run `./START-LINUX.sh` to start system |

**Instructions for your friends:**
1. Extract the zip
2. Double-click the script for their OS
3. Wait 2-3 minutes
4. Browser opens automatically to http://localhost:3000

That's it! They don't need to know anything about Docker or commands.

---

### 👨‍💻 Frontend Developer Setup

| Script | Purpose |
|--------|---------|
| `FRONTEND-DEV-SETUP.sh` | Starts backend, helps setup frontend locally |

**For the frontend developer:**
```bash
./FRONTEND-DEV-SETUP.sh
```

This will:
- ✅ Start all backend services in Docker
- ✅ Leave frontends for local development
- ✅ Give option to start any frontend with hot-reload
- ✅ Install dependencies automatically

**Then they can work on:**
- Customer Portal (Port 3000)
- Branch Dashboard (Port 3001)
- Central Bank Portal (Port 3002)

All changes hot-reload instantly!

---

### 🧪 Testing Scripts

#### Create Test Data
```bash
./CREATE-TEST-DATA.sh
```
Creates sample data:
- ✅ 5 test customers
- ✅ 7 test accounts
- ✅ 5 test transactions

Perfect for demoing the system or testing features.

#### Setup Unit Tests
```bash
./SETUP-UNIT-TESTS.sh
```
- Creates test structure for all services
- Adds sample unit tests
- Sets up JUnit dependencies

#### Run All Unit Tests
```bash
./RUN-ALL-TESTS.sh
```
- Runs unit tests for all 8 services
- Shows pass/fail summary
- Quick verification that code works

#### Run Integration Tests
```bash
./RUN-INTEGRATION-TESTS.sh
```
- Tests entire system end-to-end
- Verifies all services communicate correctly
- Tests API endpoints
- Checks database connectivity

---

### 🔬 Experimentation Tool

```bash
./EXPERIMENT.sh
```

**Interactive menu for:**

**Data Management:**
- Add test customer
- Add test account
- Create test transaction
- Generate random data (10 customers)
- Clear ALL data (fresh start)

**Service Management:**
- Restart a service
- View service logs
- Stop a service
- Start a service

**Testing:**
- Run integration tests
- Test API endpoint
- Health check all services

Perfect for playing around and testing different scenarios!

---

### 🏥 Health Check

```bash
./health-check.sh
```

Checks if all services are running:
- ✅ All 8 microservices
- ✅ All 3 frontends
- ✅ Database
- ✅ Kafka

Shows ✓ or ✗ for each service.

---

## 🎯 Quick Reference

### For Non-Technical Friends
```bash
# Windows
START-WINDOWS.bat

# Mac
./START-MAC.sh

# Linux
./START-LINUX.sh
```

### For Frontend Developer
```bash
./FRONTEND-DEV-SETUP.sh
# Then choose which frontend to work on
```

### For Testing & Experimenting
```bash
./CREATE-TEST-DATA.sh          # Add sample data
./EXPERIMENT.sh                # Interactive tool
./RUN-INTEGRATION-TESTS.sh    # Verify system works
```

### For Development
```bash
./SETUP-UNIT-TESTS.sh         # Setup tests
./RUN-ALL-TESTS.sh            # Run all tests
./health-check.sh              # Check system health
```

---

## 📋 Common Scenarios

### Scenario 1: Friend Wants to See the System
```bash
# Give them START-WINDOWS.bat or START-MAC.sh
# They double-click and it just works!
```

### Scenario 2: Frontend Dev Needs to Work
```bash
./FRONTEND-DEV-SETUP.sh
# Select option 2 for Branch Dashboard
# They can now edit and see changes instantly
```

### Scenario 3: Demo the System
```bash
# Start system
./START-MAC.sh

# Add demo data
./CREATE-TEST-DATA.sh

# Show them the portals with real data!
```

### Scenario 4: Test a New Feature
```bash
# Start experimentation mode
./EXPERIMENT.sh

# Choose option 1-4 to add test data
# Choose option 11 to test API endpoint
# Choose option 12 to verify health
```

### Scenario 5: Verify Everything Works
```bash
# Health check
./health-check.sh

# Integration tests
./RUN-INTEGRATION-TESTS.sh

# If all pass - system is good!
```

---

## 🔧 Troubleshooting

### Script won't run (Mac/Linux)
```bash
chmod +x SCRIPT-NAME.sh
./SCRIPT-NAME.sh
```

### Windows "Access Denied"
- Right-click the .bat file
- Properties → Unblock → OK
- Try again

### Docker not found
- Install Docker Desktop
- Make sure it's running
- Try script again

### Services fail to start
```bash
# Stop everything
docker-compose down

# Start fresh
./START-MAC.sh  # or your platform
```

---

## 💡 Tips

1. **First Time:** Use the platform-specific START script
2. **Frontend Work:** Use FRONTEND-DEV-SETUP.sh
3. **Testing:** Use EXPERIMENT.sh - it's interactive!
4. **CI/CD:** Use RUN-ALL-TESTS.sh and RUN-INTEGRATION-TESTS.sh
5. **Demos:** Run CREATE-TEST-DATA.sh first

---

## 📚 Script Details

### START Scripts (All Platforms)
- Check Docker is installed
- Check Docker is running
- Start infrastructure (DB, Kafka)
- Start all microservices
- Start API Gateway
- Start all frontends
- Open browser automatically
- Show access URLs

### FRONTEND-DEV-SETUP.sh
- Starts only backend in Docker
- Leaves frontends for local dev
- Interactive menu to choose frontend
- Runs `npm install` automatically
- Starts dev server with hot-reload

### CREATE-TEST-DATA.sh
- Calls API to create customers
- Creates accounts for customers
- Adds sample transactions
- Uses realistic test data
- Shows summary of created data

### EXPERIMENT.sh
- Interactive menu system
- Add/remove data easily
- Restart services on-the-fly
- View logs in real-time
- Test API endpoints
- Health checks

### Test Scripts
- SETUP-UNIT-TESTS.sh: Creates test files
- RUN-ALL-TESTS.sh: Runs all service tests
- RUN-INTEGRATION-TESTS.sh: Tests entire system

---

## 🎉 Success!

Your friends can now run the system with ONE CLICK.
Your frontend dev can work with hot-reload easily.
You can test and experiment without any hassle.

**Everything is automated!** 🚀
