#!/bin/bash

set -e

DRY_RUN=false
FORCE=false
DEBUG=false

usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS] <directory>

Remove node_modules and temporary files recursively from a directory.

OPTIONS:
  -h, --help      Show this help message
  -n, --dry-run   Show what would be deleted without actually deleting
  -f, --force     Skip confirmation prompt
  -d, --debug     Enable debug output

EXAMPLES:
  $(basename "$0") /path/to/project
  $(basename "$0") -n /path/to/project    # preview only
  $(basename "$0") -f /path/to/project     # auto-confirm
  $(basename "$0") -d /path/to/project     # debug mode

TARGETS:
  - node_modules, .next, .nuxt, .turbo (directories)
  - *.tmp, *.temp, *~ (temporary files)
  - __pycache__ (Python cache)
EOF
  exit 0
}

debug() {
  [[ "$DEBUG" == "true" ]] && echo "[DEBUG] $*" >&2
}

confirm() {
  read -p "Delete $1 items? [y/N] " -n 1 -r
  echo
  [[ $REPLY =~ ^[Yy]$ ]]
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) usage ;;
    -n|--dry-run) DRY_RUN=true ;;
    -f|--force) FORCE=true ;;
    -d|--debug) DEBUG=true ;;
    -*) echo "Unknown option: $1" >&2; exit 1 ;;
    *) TARGET="$1" ;;
  esac
  shift
done

if [[ -z "$TARGET" ]]; then
  echo "Error: directory is required"
  echo "Run with --help for usage"
  exit 1
fi

if [[ ! -d "$TARGET" ]]; then
  echo "Error: '$TARGET' is not a valid directory"
  exit 1
fi

debug "Starting scan in: $TARGET"
debug "Finding items..."

mapfile -t items < <(find "$TARGET" \( -type d -name "node_modules" -o -type d -name ".next" -o -type d -name ".nuxt" -o -type d -name ".turbo" -o -type d -name "__pycache__" -o -type f -name "*.tmp" -o -type f -name "*.temp" -o -type f -name "*~" \) -not -path "*/node_modules/*" -not -path "*/dist/*" -not -path "*/.cxx/*" -not -path "*/build/*" -not -path "*/target/*" 2>/dev/null)

debug "Found ${#items[@]} items to process"

if [[ ${#items[@]} -eq 0 ]]; then
  debug "No items found to clean"
  echo "No items to clean"
  exit 0
fi

total=0
space_freed=0

for item in "${items[@]}"; do
  size=$(du -sb "$item" 2>/dev/null | cut -f1) || size=0
  ((total++)) || true
  ((space_freed += size)) || true
  debug "Found: $item (${size}B)"
  echo "$item ($(numfmt --to=iec-i --suffix=B $size 2>/dev/null || echo "${size}B"))"
done

human_size=$(numfmt --to=iec-i --suffix=B $space_freed 2>/dev/null || echo "${space_freed} bytes")
echo ""
echo "Total: $total items, $human_size"

debug "Total size: $space_freed bytes"

if [[ "$DRY_RUN" == "true" ]]; then
  debug "Dry run mode - exiting"
  echo ""
  echo "Dry run - nothing deleted"
  exit 0
fi

if [[ "$FORCE" != "true" ]]; then
  debug "Waiting for confirmation"
  echo ""
  confirm "$total" || { echo "Cancelled"; exit 0; }
else
  debug "Force mode - skipping confirmation"
fi

debug "Starting deletion..."
for item in "${items[@]}"; do
  debug "Deleting: $item"
  rm -rf "$item"
done
debug "Deletion complete"

echo "Cleaned $total items, freed $human_size"