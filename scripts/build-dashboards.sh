#!/bin/bash

set -e

echo "🔨 Building Grafana dashboards from Jsonnet..."

# Check if running in Docker or native
if [ -f /.dockerenv ] || grep -q 'docker\|lxc' /proc/1/cgroup 2>/dev/null; then
    echo "📦 Running in Docker container"
    IN_DOCKER=true
else
    echo "💻 Running on host machine"
    IN_DOCKER=false
fi

# Check if tools are available
if ! command -v jsonnet &> /dev/null; then
    if [ "$IN_DOCKER" = false ]; then
        echo "❌ jsonnet not found!"
        echo ""
        echo "Option 1: Install locally (recommended for development)"
        echo "  macOS:   brew install jsonnet jsonnet-bundler"
        echo "  Ubuntu:  sudo apt-get install jsonnet && go install github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb@latest"
        echo ""
        echo "Option 2: Use Docker"
        echo "  docker run --rm -v \$(pwd):/workspace -w /workspace \$(docker build -q -f Dockerfile.jsonnet .) -c 'make dashboards'"
        echo ""
        exit 1
    else
        echo "❌ jsonnet not available in container"
        exit 1
    fi
fi

if ! command -v jb &> /dev/null; then
    echo "❌ jsonnet-bundler (jb) not found!"
    echo "Install it: brew install jsonnet-bundler"
    exit 1
fi

# Install dependencies if needed
if [ ! -d "vendor" ]; then
    echo "📚 Installing grafonnet library..."
    jb install
else
    echo "✅ Dependencies already installed"
fi

# Build dashboards
echo "🏗️  Building dashboards..."
make dashboards

echo "✅ Done! Dashboards generated in config/grafana/dashboards/"
