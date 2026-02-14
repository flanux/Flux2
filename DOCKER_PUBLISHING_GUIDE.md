# 🐳 Docker Image Publishing Guide

This guide explains how to publish FLUX Docker images to GitHub Container Registry (GHCR) for faster deployment.

## 🎯 Why Publish Docker Images?

### Without Publishing (Current)
```bash
./flux-start.sh
# → Builds 12 images from scratch (5-10 minutes)
# → Downloads all dependencies
# → Requires Docker build expertise
```

### With Publishing (After Setup)
```bash
docker-compose -f docker-compose.prod.yml up -d
# → Pulls pre-built images (30 seconds)
# → No build time
# → Just works!
```

**This makes FLUX look 10x more professional to investors and users.**

---

## 📦 What Gets Published

FLUX publishes 12 Docker images to GHCR:

### Backend Services (8 images)
- `ghcr.io/YOUR_USERNAME/flux-account-service`
- `ghcr.io/YOUR_USERNAME/flux-customer-service`
- `ghcr.io/YOUR_USERNAME/flux-card-service`
- `ghcr.io/YOUR_USERNAME/flux-ledger-service`
- `ghcr.io/YOUR_USERNAME/flux-loan-service`
- `ghcr.io/YOUR_USERNAME/flux-notification-service`
- `ghcr.io/YOUR_USERNAME/flux-reporting-service`
- `ghcr.io/YOUR_USERNAME/flux-transaction-service`

### Infrastructure (1 image)
- `ghcr.io/YOUR_USERNAME/flux-api-gateway`

### Frontends (3 images)
- `ghcr.io/YOUR_USERNAME/flux-customer-portal`
- `ghcr.io/YOUR_USERNAME/flux-branch-dashboard`
- `ghcr.io/YOUR_USERNAME/flux-central-bank-portal`

---

## 🚀 Quick Setup (First Time)

### 1. Enable GitHub Container Registry

Go to your repository settings:
```
https://github.com/YOUR_USERNAME/flux/settings/packages
```

✅ Make sure package publishing is enabled

### 2. Create Release to Trigger Publishing

```bash
# Method 1: Using Git Tags
git tag v1.0.0
git push origin v1.0.0

# Method 2: Using GitHub CLI
gh release create v1.0.0 --title "FLUX v1.0.0 - Confluence"

# Method 3: GitHub Web Interface
# Go to Releases → Draft new release → Create tag v1.0.0
```

### 3. Wait for GitHub Actions

GitHub Actions will automatically:
1. Build all 12 Docker images
2. Push them to GHCR
3. Tag them with version number

**Time:** ~10-15 minutes for all images

### 4. Verify Images

Check your packages page:
```
https://github.com/YOUR_USERNAME?tab=packages
```

You should see 12 packages starting with `flux-*`

---

## 🎮 How to Use Published Images

### Option 1: Production Deployment (Recommended)

```bash
# 1. Set your GitHub username in .env
echo "GITHUB_USER=YOUR_USERNAME" >> .env

# 2. Deploy using production compose file
docker-compose -f docker-compose.prod.yml up -d

# Done! Everything runs in 30 seconds.
```

### Option 2: Specific Version

```bash
# Deploy v1.0.0 specifically
export VERSION=v1.0.0
docker-compose -f docker-compose.prod.yml up -d
```

### Option 3: Development (Build Locally)

```bash
# Use regular docker-compose for development
docker-compose up -d

# This still builds locally for quick iteration
```

---

## 🔄 Publishing New Versions

Every time you create a new release, images are automatically published!

### Creating a New Release

```bash
# 1. Make your changes
git add .
git commit -m "Add new features"
git push

# 2. Create new version tag
git tag v1.1.0
git push origin v1.1.0

# 3. Images automatically build and publish!
```

### What Gets Tagged

Each image gets multiple tags:
- `v1.1.0` - Exact version
- `v1.1` - Minor version
- `v1` - Major version
- `latest` - Always points to newest
- `sha-abc123` - Commit hash

---

## 🏷️ Image Tagging Strategy

FLUX uses semantic versioning:

```
v1.0.0
│ │ │
│ │ └─ Patch: Bug fixes
│ └─── Minor: New features (backward compatible)
└───── Major: Breaking changes
```

### Examples

| Release | Tags Created | Use Case |
|---------|-------------|----------|
| `v1.0.0` | `v1.0.0`, `v1.0`, `v1`, `latest` | First stable release |
| `v1.1.0` | `v1.1.0`, `v1.1`, `v1`, `latest` | New features |
| `v1.1.1` | `v1.1.1`, `v1.1`, `v1`, `latest` | Bug fix |
| `v2.0.0` | `v2.0.0`, `v2.0`, `v2`, `latest` | Breaking changes |

---

## 🔐 Making Images Public

By default, GHCR images are private. To make them public:

1. Go to package settings:
   ```
   https://github.com/users/YOUR_USERNAME/packages/container/flux-account-service/settings
   ```

2. Scroll to "Danger Zone"

3. Click "Change visibility" → Select "Public"

4. Repeat for all 12 packages (or use API)

### Bulk Make Public (Advanced)

```bash
# Install GitHub CLI first: https://cli.github.com/

# Make all flux packages public
for pkg in account-service customer-service card-service ledger-service \
           loan-service notification-service reporting-service transaction-service \
           api-gateway customer-portal branch-dashboard central-bank-portal; do
  gh api \
    --method PATCH \
    -H "Accept: application/vnd.github+json" \
    /user/packages/container/flux-$pkg \
    -f visibility='public'
done
```

---

## 📊 Benefits of Publishing

### For Development
✅ Faster CI/CD pipelines  
✅ Consistent builds across team  
✅ Easy rollback to previous versions  
✅ No "works on my machine" issues

### For Deployment
✅ 30 second startup vs 10 minutes  
✅ Lower bandwidth usage  
✅ Production-ready images  
✅ Version control

### For Investors/Users
✅ Professional appearance  
✅ One-command deployment  
✅ Clear versioning  
✅ Enterprise-ready

---

## 🐛 Troubleshooting

### "Failed to push image"
**Solution:** Check GitHub Actions has package write permissions
```
Settings → Actions → General → Workflow permissions
Select: "Read and write permissions"
```

### "Image not found"
**Solution:** Make sure GITHUB_USER is set correctly
```bash
echo "GITHUB_USER=YOUR_USERNAME" >> .env
# Replace YOUR_USERNAME with your actual GitHub username
```

### "Rate limit exceeded"
**Solution:** Authenticate with Docker
```bash
echo $GITHUB_TOKEN | docker login ghcr.io -u YOUR_USERNAME --password-stdin
```

### "Permission denied"
**Solution:** Make sure you're logged in
```bash
# Create personal access token with packages:write scope
# Then login:
docker login ghcr.io
```

---

## 🎯 Best Practices

### 1. **Always Tag Releases**
```bash
# Good: Creates versioned images
git tag v1.0.0 && git push origin v1.0.0

# Bad: Only pushes code, no images
git push
```

### 2. **Use Semantic Versioning**
```bash
v1.0.0 → First release
v1.1.0 → New features
v1.1.1 → Bug fix
v2.0.0 → Breaking changes
```

### 3. **Pin Versions in Production**
```bash
# Good: Explicit version
VERSION=v1.0.0 docker-compose -f docker-compose.prod.yml up -d

# Risky: Always uses latest
docker-compose -f docker-compose.prod.yml up -d
```

### 4. **Test Before Publishing**
```bash
# Build and test locally first
docker-compose up -d
./flux-playground.sh  # Run tests

# Then publish
git tag v1.0.0 && git push origin v1.0.0
```

---

## 🎓 Advanced: Manual Publishing

If you want to publish without GitHub Actions:

```bash
# 1. Login to GHCR
echo $GITHUB_TOKEN | docker login ghcr.io -u YOUR_USERNAME --password-stdin

# 2. Build an image
docker build -t ghcr.io/YOUR_USERNAME/flux-account-service:v1.0.0 \
  ./services/account-service

# 3. Push it
docker push ghcr.io/YOUR_USERNAME/flux-account-service:v1.0.0

# 4. Tag as latest
docker tag ghcr.io/YOUR_USERNAME/flux-account-service:v1.0.0 \
  ghcr.io/YOUR_USERNAME/flux-account-service:latest

docker push ghcr.io/YOUR_USERNAME/flux-account-service:latest
```

But GitHub Actions does this automatically! 🎉

---

## 📝 Summary

| Task | Command |
|------|---------|
| **Setup** | Create GitHub release or push tag |
| **Deploy** | `docker-compose -f docker-compose.prod.yml up -d` |
| **Update** | Create new release with new version tag |
| **Rollback** | `VERSION=v1.0.0 docker-compose -f docker-compose.prod.yml up -d` |

**That's it!** Publishing Docker images makes FLUX deployment professional and fast! 🚀
