.PHONY: dashboards clean install-deps dashboards-docker

# Directories
JSONNET_DIR := dashboards-jsonnet
OUTPUT_DIR := config/grafana/dashboards
VENDOR_DIR := vendor

# Find all .jsonnet files
JSONNET_FILES := $(shell find $(JSONNET_DIR) -name '*.jsonnet' -not -path '$(JSONNET_DIR)/lib/*')
JSON_FILES := $(patsubst $(JSONNET_DIR)/%.jsonnet,$(OUTPUT_DIR)/%.json,$(JSONNET_FILES))

# Default target
all: dashboards

# Install jsonnet-bundler dependencies
install-deps:
	@echo "Installing grafonnet library..."
	@command -v jb >/dev/null 2>&1 || { echo "jsonnet-bundler (jb) not found. Install it first: brew install jsonnet-bundler"; exit 1; }
	jb install

# Build all dashboards
dashboards: $(JSON_FILES)
	@echo "All dashboards built successfully!"

# Build individual dashboard
$(OUTPUT_DIR)/%.json: $(JSONNET_DIR)/%.jsonnet
	@echo "Building $<..."
	@mkdir -p $(dir $@)
	@command -v jsonnet >/dev/null 2>&1 || { echo "jsonnet not found. Install it first: brew install jsonnet"; exit 1; }
	jsonnet -J $(VENDOR_DIR) $< -o $@

# Clean generated files
clean:
	@echo "Cleaning generated dashboards..."
	find $(OUTPUT_DIR) -name '*.json' -type f -delete

# Watch for changes (requires entr)
watch:
	@command -v entr >/dev/null 2>&1 || { echo "entr not found. Install it first: brew install entr"; exit 1; }
	find $(JSONNET_DIR) -name '*.jsonnet' -o -name '*.libsonnet' | entr -r make dashboards

# Validate jsonnet syntax
validate:
	@echo "Validating jsonnet files..."
	@for file in $(JSONNET_FILES); do \
		echo "Validating $$file..."; \
		jsonnet -J $(VENDOR_DIR) $$file > /dev/null || exit 1; \
	done
	@echo "All files valid!"

# Build dashboards using Docker (no local installation needed)
dashboards-docker:
	@echo "Building dashboards using Docker..."
	@docker build -t jsonnet-builder -f Dockerfile.jsonnet .
	@docker run --rm -v $(PWD):/workspace -w /workspace jsonnet-builder -c "jb install && make dashboards"

help:
	@echo "Available targets:"
	@echo "  make install-deps     - Install grafonnet library using jsonnet-bundler"
	@echo "  make dashboards       - Build all dashboards (default, requires local tools)"
	@echo "  make dashboards-docker - Build dashboards using Docker (no local install needed)"
	@echo "  make clean            - Remove generated JSON files"
	@echo "  make validate         - Validate jsonnet syntax"
	@echo "  make watch            - Watch for changes and rebuild (requires entr)"
	@echo "  make help             - Show this help message"