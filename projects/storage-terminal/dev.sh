#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Storage Terminal — Dev Setup ==="
echo ""

# Install dependencies
echo "[1/3] Installing relay dependencies..."
cd "$SCRIPT_DIR/relay"
bun install --silent

echo "[2/3] Installing web dependencies..."
cd "$SCRIPT_DIR/web"
bun install --silent

echo "[3/3] Building web frontend..."
bun run build

echo ""
echo "=== Starting relay server ==="
echo "Web UI: http://localhost:3001"
echo "Health: http://localhost:3001/health"
echo "Press Ctrl+C to stop"
echo ""

cd "$SCRIPT_DIR/relay"
bun run index.ts
