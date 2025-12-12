#!/bin/bash
set -e

# Clean resource forks before code signing
find "$BUILT_PRODUCTS_DIR" -type f \( -name "._*" -o -name ".DS_Store" \) -delete 2>/dev/null || true
xattr -cr "$BUILT_PRODUCTS_DIR" 2>/dev/null || true
dot_clean "$BUILT_PRODUCTS_DIR" 2>/dev/null || true

exit 0
