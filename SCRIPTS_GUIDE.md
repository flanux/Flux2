# 🚀 Scripts Guide

Complete guide to all scripts in the banking system.

## 📁 Available Scripts

### 1. **System Startup Scripts** (For Your Friends)

#### Windows
```bash
start-windows.bat
```
**What it does:**
- Checks Docker is running
- Checks ports are available
- Starts all services in correct order
- Shows success message with URLs
- Zero configuration needed!

**Your friends just need to:**
1. Double-click `start-windows.bat`
2. Wait 3-5 minutes
3. Visit http://localhost:3000

#### Mac/Linux
```bash
./start-mac-linux.sh
```
**What it does:**
- Same as Windows version
- Opens browser automatically (Mac)
- Colored output for easy reading

**Your friends just need to:**
1. Open Terminal
2. Navigate to folder
3. Run: `./start-mac-linux.sh`
4. Visit http://localhost:3000

---

### 2. **Frontend Developer Scripts**

#### Windows
```bash
frontend-dev-windows.bat
```

#### Mac/Linux
```bash
./frontend-dev-mac-linux.sh
```

**What it does:**
- Detects Node.js and npm
- Lets developer choose which frontend to work on
- Auto-installs dependencies
- Starts dev server with hot-reload
- Opens browser automatically

**Features:**
- Choose single frontend or all 3
- Auto npm install if needed
- Separate terminals for each frontend
- Backend check (warns if not running)

**Usage:**
```
Select Frontend:
1. Customer Portal (3000)
2. Branch Dashboard (3001)  
3. Central Bank Portal (3002)
4. All Frontends
```

---

### 3. **Test Runner Script**

```bash
./run-tests.sh
```

**What it does:**
- Runs unit tests for all services
- Runs integration/system tests
- Runs frontend tests
- Generates HTML test report

**Test Options:**
1. **Unit Tests** - Tests each service individually
2. **System Tests** - Tests service integration
3. **Frontend Tests** - Tests React components
4. **All Tests** - Runs everything
5. **Generate Report** - Creates HTML report

**Example Output:**
```
✓ account-service tests passed
✓ customer-service tests passed
✗ card-service tests failed
```

**HTML Report:**
- Auto-generated with timestamp
- Shows all service health
- Opens in browser automatically

---

### 4. **Playground Script** (Testing & Experimentation)

```bash
./playground.sh
```

**What it does:**
- Generates test data
- Adds/removes sample data
- Creates demo scenarios
- Views current data

**Features:**

#### 🎲 Generate Random Data
```
Option 1: Generate Random Test Data
- Creates N random customers
- Random names, emails, phones
```

#### 👤 Add Sample Customers
```
Option 2: Add Sample Customers
- Alice Wonder
- Bob Builder
- Charlie Chocolate
```

#### 🏦 Add Sample Accounts
```
Option 3: Add Sample Accounts
- Creates 5 accounts
- Random types (Savings/Checking/Fixed)
- Random balances
```

#### 💳 Add Sample Cards
```
Option 4: Add Sample Cards
- Debit and Credit cards
- Linked to accounts
```

#### 💰 Add Sample Loans
```
Option 5: Add Sample Loans
- Personal, Home, Auto, Education
- Random amounts and tenures
```

#### 💸 Generate Transactions
```
Option 6: Generate Sample Transactions
- 10 random transactions
- Deposits and withdrawals
```

#### 🗑️ Clear All Data
```
Option 7: Clear All Test Data
- Removes everything
- Fresh start
```

#### 📊 View Current Data
```
Option 8: View Current Data
- Shows counts:
  * Customers: 10
  * Accounts: 5
  * Cards: 3
  * Loans: 4
  * Transactions: 10
```

#### 🎪 Full Demo Scenario
```
Option 9: Run Full Demo
- Creates complete demo dataset
- 10 customers
- 5 accounts
- 3 cards
- 4 loans
- 10 transactions
```

---

## 🎯 Quick Reference

### For Your Friends (Just Want to Use It)

**Windows:**
```bash
# Just double-click:
start-windows.bat
```

**Mac/Linux:**
```bash
./start-mac-linux.sh
```

**Done!** They can now use the system.

---

### For Frontend Developers

**Windows:**
```bash
frontend-dev-windows.bat
```

**Mac/Linux:**
```bash
./frontend-dev-mac-linux.sh
```

**What they get:**
- Hot-reload dev environment
- Auto npm install
- Browser auto-opens
- All 3 frontends available

---

### For Testing

**Run All Tests:**
```bash
./run-tests.sh
# Select option 4 (All Tests)
```

**Quick Health Check:**
```bash
./health-check.sh
```

**Add Test Data:**
```bash
./playground.sh
# Select option 9 (Full Demo)
```

---

## 📚 Common Scenarios

### Scenario 1: Friend Wants to Try System

**Tell them:**
1. Extract the zip
2. Windows: Double-click `start-windows.bat`
3. Mac/Linux: Run `./start-mac-linux.sh`
4. Wait 3 minutes
5. Visit http://localhost:3000

**No other knowledge needed!**

---

### Scenario 2: Frontend Dev Joins Team

**Tell them:**
1. Run backend: `./start-mac-linux.sh`
2. In new terminal: `./frontend-dev-mac-linux.sh`
3. Choose which frontend to work on
4. Code with hot-reload!

**No Docker knowledge needed!**

---

### Scenario 3: Need Test Data

**Quick demo data:**
```bash
./playground.sh
# Choose 9 (Full Demo)
```

**Custom data:**
```bash
./playground.sh
# Choose what you need:
# - Random customers
# - Sample accounts
# - Test transactions
```

---

### Scenario 4: Want to Run Tests

**Before deploying:**
```bash
./run-tests.sh
# Choose 4 (All Tests)
```

**Check specific service:**
```bash
./run-tests.sh
# Choose 1 (Unit Tests)
```

**See results:**
- Terminal output
- HTML report (auto-opens)

---

## 🔧 Troubleshooting Scripts

### Script Won't Run (Mac/Linux)

**Fix permissions:**
```bash
chmod +x *.sh
```

### "Docker not running"

**Start Docker:**
- Windows: Start Docker Desktop
- Mac: Start Docker Desktop
- Linux: `sudo systemctl start docker`

### "Port already in use"

**Find what's using it:**
```bash
# Mac/Linux
lsof -i :3000

# Windows
netstat -ano | findstr :3000
```

**Kill it or change port in docker-compose.yml**

### Frontend dependencies fail

**Manual install:**
```bash
cd frontends/branch-dashboard
rm -rf node_modules package-lock.json
npm install
```

---

## 🎨 Customization

### Change Ports

**Edit docker-compose.yml:**
```yaml
customer-portal:
  ports:
    - "3050:80"  # Change 3000 to 3050
```

### Add More Test Data

**Edit playground.sh:**
```bash
# Change line:
FIRST_NAMES=("John" "Jane" ...)
# Add more names!
```

### Modify Startup Order

**Edit start scripts:**
```bash
# Change wait times:
sleep 20  # Make longer if services slow to start
```

---

## 📊 Script Features Comparison

| Feature | Startup | Frontend Dev | Test Runner | Playground |
|---------|---------|--------------|-------------|------------|
| Start Backend | ✅ | ❌ | ❌ | ❌ |
| Start Frontend | ✅ | ✅ | ❌ | ❌ |
| Hot Reload | ❌ | ✅ | ❌ | ❌ |
| Run Tests | ❌ | ❌ | ✅ | ❌ |
| Add Data | ❌ | ❌ | ❌ | ✅ |
| Zero Config | ✅ | ✅ | ❌ | ❌ |

---

## 🎓 Teaching Your Friends

### For Non-Technical Friends

**Just tell them:**
> "Double-click the start-windows.bat file, wait 3 minutes, then go to localhost:3000 in your browser. That's it!"

### For Frontend Developers

**Tell them:**
> "Run the frontend dev script, choose which portal you want to work on, and you're good to go. The backend is already running."

### For Testers

**Tell them:**
> "Use playground.sh to add test data. Option 9 creates a full demo scenario. Use run-tests.sh to run all tests."

---

## 🚀 Pro Tips

1. **Always run startup script first** before dev/test scripts
2. **Use playground for demos** - creates realistic data fast
3. **Run tests before committing** - catches issues early
4. **Frontend dev script is isolated** - won't affect backend
5. **All scripts have colored output** - easy to read
6. **Check health-check.sh regularly** - spot issues fast

---

## 📝 Summary

| I Want To... | Use This Script |
|-------------|----------------|
| Just start everything | `start-windows.bat` or `start-mac-linux.sh` |
| Develop frontend | `frontend-dev-windows.bat` or `frontend-dev-mac-linux.sh` |
| Run tests | `run-tests.sh` |
| Add test data | `playground.sh` |
| Check health | `health-check.sh` |

---

**All scripts are zero-config and beginner-friendly!** 🎉
