#!/bin/bash

# ==============================================================================
# FLUX Release Publisher
# ==============================================================================
# This script helps you create and publish a new FLUX release
#
# Usage:
#   ./publish-release.sh v1.0.0 "First stable release"
#   ./publish-release.sh v1.1.0 "Added new features"
# ==============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Check arguments
if [ $# -lt 1 ]; then
    echo -e "${RED}Error: Version number required${NC}"
    echo ""
    echo "Usage:"
    echo "  $0 <version> [description]"
    echo ""
    echo "Examples:"
    echo "  $0 v1.0.0 \"First stable release\""
    echo "  $0 v1.1.0 \"Added branch reports feature\""
    echo "  $0 v2.0.0 \"Major architecture update\""
    exit 1
fi

VERSION=$1
DESCRIPTION=${2:-"FLUX Banking System $VERSION"}

# Validate version format
if ! [[ $VERSION =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo -e "${RED}Error: Invalid version format${NC}"
    echo -e "${YELLOW}Version must be in format: vX.Y.Z (e.g., v1.0.0)${NC}"
    exit 1
fi

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                                                            ║${NC}"
echo -e "${BLUE}║           🌊 FLUX Release Publisher                        ║${NC}"
echo -e "${BLUE}║                                                            ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Display release info
echo -e "${PURPLE}📦 Release Information:${NC}"
echo -e "   Version:     ${GREEN}$VERSION${NC}"
echo -e "   Description: ${YELLOW}$DESCRIPTION${NC}"
echo ""

# Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo -e "${RED}❌ You have uncommitted changes${NC}"
    echo -e "${YELLOW}   Please commit or stash your changes first${NC}"
    echo ""
    git status --short
    exit 1
fi

echo -e "${GREEN}✅ No uncommitted changes${NC}"
echo ""

# Check if tag already exists
if git tag -l | grep -q "^$VERSION$"; then
    echo -e "${RED}❌ Tag $VERSION already exists${NC}"
    echo -e "${YELLOW}   Use a different version number${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Version $VERSION is available${NC}"
echo ""

# Confirm with user
echo -e "${YELLOW}❓ Ready to publish release $VERSION?${NC}"
echo -e "${YELLOW}   This will:${NC}"
echo -e "     1. Create git tag $VERSION"
echo -e "     2. Push to GitHub"
echo -e "     3. Trigger automatic Docker image builds"
echo -e "     4. Publish 12 images to GitHub Container Registry"
echo ""
read -p "Continue? (y/N) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Cancelled${NC}"
    exit 0
fi

echo ""
echo -e "${BLUE}🚀 Publishing release...${NC}"
echo ""

# Create tag
echo -e "${YELLOW}1️⃣  Creating git tag $VERSION...${NC}"
git tag -a "$VERSION" -m "$DESCRIPTION"
echo -e "${GREEN}   ✅ Tag created${NC}"
echo ""

# Push tag
echo -e "${YELLOW}2️⃣  Pushing tag to GitHub...${NC}"
git push origin "$VERSION"
echo -e "${GREEN}   ✅ Tag pushed${NC}"
echo ""

# Push main branch (in case of commits)
echo -e "${YELLOW}3️⃣  Ensuring main branch is up to date...${NC}"
git push origin main 2>/dev/null || git push origin master 2>/dev/null || true
echo -e "${GREEN}   ✅ Branch updated${NC}"
echo ""

echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Release $VERSION published!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo ""

# Get GitHub username
GITHUB_USER=$(git config --get remote.origin.url | sed -n 's#.*/\([^/]*\)/.*#\1#p')
REPO_NAME=$(git config --get remote.origin.url | sed -n 's#.*/\([^/]*\)\.git#\1#p')

echo -e "${BLUE}📋 What happens next:${NC}"
echo ""
echo -e "${YELLOW}1. GitHub Actions Building (10-15 minutes)${NC}"
echo -e "   GitHub is now building and publishing Docker images"
echo -e "   Watch progress:"
echo -e "   ${BLUE}https://github.com/$GITHUB_USER/$REPO_NAME/actions${NC}"
echo ""
echo -e "${YELLOW}2. Images Will Be Published To:${NC}"
echo -e "   • ghcr.io/$GITHUB_USER/flux-account-service:$VERSION"
echo -e "   • ghcr.io/$GITHUB_USER/flux-customer-service:$VERSION"
echo -e "   • ghcr.io/$GITHUB_USER/flux-card-service:$VERSION"
echo -e "   • ghcr.io/$GITHUB_USER/flux-ledger-service:$VERSION"
echo -e "   • ghcr.io/$GITHUB_USER/flux-loan-service:$VERSION"
echo -e "   • ghcr.io/$GITHUB_USER/flux-notification-service:$VERSION"
echo -e "   • ghcr.io/$GITHUB_USER/flux-reporting-service:$VERSION"
echo -e "   • ghcr.io/$GITHUB_USER/flux-transaction-service:$VERSION"
echo -e "   • ghcr.io/$GITHUB_USER/flux-api-gateway:$VERSION"
echo -e "   • ghcr.io/$GITHUB_USER/flux-customer-portal:$VERSION"
echo -e "   • ghcr.io/$GITHUB_USER/flux-branch-dashboard:$VERSION"
echo -e "   • ghcr.io/$GITHUB_USER/flux-central-bank-portal:$VERSION"
echo ""
echo -e "${YELLOW}3. Create GitHub Release (Optional)${NC}"
echo -e "   Create a formal release with release notes:"
echo -e "   ${BLUE}https://github.com/$GITHUB_USER/$REPO_NAME/releases/new?tag=$VERSION${NC}"
echo ""
echo -e "${YELLOW}4. After Images Are Built${NC}"
echo -e "   Users can deploy FLUX in 30 seconds:"
echo ""
echo -e "   ${GREEN}# Set version in .env${NC}"
echo -e "   ${BLUE}echo \"VERSION=$VERSION\" >> .env${NC}"
echo ""
echo -e "   ${GREEN}# Deploy${NC}"
echo -e "   ${BLUE}docker-compose -f docker-compose.prod.yml up -d${NC}"
echo ""
echo -e "${YELLOW}5. Make Images Public (If Needed)${NC}"
echo -e "   Go to package settings and change visibility to public:"
echo -e "   ${BLUE}https://github.com/$GITHUB_USER?tab=packages${NC}"
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${GREEN}🎉 Release $VERSION is being published!${NC}"
echo ""
