#!/bin/bash
echo ""
echo "╔═══════════════════════════════════════════╗"
echo "║         FLUX Banking System v2.0          ║"
echo "╚═══════════════════════════════════════════╝"
echo ""
echo "🛑 Stopping existing containers..."
docker compose down 2>/dev/null
echo "🗄️  Starting infrastructure (DB, Redis, Kafka)..."
docker compose up -d database redis zookeeper kafka
echo "⏳ Waiting for database..."
until docker exec banking-database pg_isready -U admin > /dev/null 2>&1; do
  echo "   → waiting..."; sleep 3
done
echo "✅ Database ready! Waiting for Kafka..."
sleep 12
echo "🚀 Starting all services..."
docker compose up -d
echo ""
echo "⏳ Services starting (Spring Boot takes ~2 minutes)..."
for i in $(seq 1 24); do
  sleep 5
  RUNNING=$(docker compose ps --format "{{.Name}} {{.Status}}" 2>/dev/null | grep -c "Up")
  echo "   [$i/24] $RUNNING containers running..."
done
echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                   FLUX IS READY! 🎉                         ║"
echo "╠══════════════════════════════════════════════════════════════╣"
if [ -n "$CODESPACE_NAME" ]; then
  echo "║  Customer Portal  → https://${CODESPACE_NAME}-3000.app.github.dev"
  echo "║  Branch Dashboard → https://${CODESPACE_NAME}-3001.app.github.dev"
  echo "║  Central Bank     → https://${CODESPACE_NAME}-3002.app.github.dev"
else
  echo "║  Customer  → http://localhost:3000"
  echo "║  Branch    → http://localhost:3001"
  echo "║  Central   → http://localhost:3002"
fi
echo "╠══════════════════════════════════════════════════════════════╣"
echo "║  ram.bahadur / Flux@2026  (Customer Portal)"
echo "║  manager.ktm / Flux@2026  (Branch Dashboard)"
echo "║  admin       / Flux@2026  (Central Bank Portal)"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
docker compose ps
