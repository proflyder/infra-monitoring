#!/bin/bash

set -e

echo "🚀 Setting up Jsonnet and Grafonnet..."

# Check if running on macOS or Linux
if [[ "$OSTYPE" == "darwin"* ]]; then
    PACKAGE_MANAGER="brew"
elif command -v apt-get &> /dev/null; then
    PACKAGE_MANAGER="apt"
elif command -v dnf &> /dev/null; then
    PACKAGE_MANAGER="dnf"
else
    echo "❌ Unsupported package manager. Please install jsonnet and jsonnet-bundler manually."
    exit 1
fi

# Install jsonnet
if ! command -v jsonnet &> /dev/null; then
    echo "📦 Installing jsonnet..."
    if [ "$PACKAGE_MANAGER" = "brew" ]; then
        brew install jsonnet
    elif [ "$PACKAGE_MANAGER" = "apt" ]; then
        sudo apt-get update && sudo apt-get install -y jsonnet
    elif [ "$PACKAGE_MANAGER" = "dnf" ]; then
        sudo dnf install -y jsonnet
    fi
else
    echo "✅ jsonnet already installed"
fi

# Install jsonnet-bundler
if ! command -v jb &> /dev/null; then
    echo "📦 Installing jsonnet-bundler..."
    if [ "$PACKAGE_MANAGER" = "brew" ]; then
        brew install jsonnet-bundler
    else
        # Install from source for Linux
        echo "Installing jsonnet-bundler from source..."
        GO_VERSION=$(go version 2>/dev/null | awk '{print $3}' | sed 's/go//')
        if [ -z "$GO_VERSION" ]; then
            echo "❌ Go is not installed. Please install Go first."
            exit 1
        fi
        go install github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb@latest
        sudo cp ~/go/bin/jb /usr/local/bin/
    fi
else
    echo "✅ jsonnet-bundler already installed"
fi

# Install grafonnet library
echo "📚 Installing grafonnet library..."
jb install

echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "  1. Edit dashboard files in dashboards-jsonnet/"
echo "  2. Run 'make dashboards' to generate JSON files"
echo "  3. Generated files will be in config/grafana/dashboards/"
