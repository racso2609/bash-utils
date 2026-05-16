#!/bin/bash

DEPTH=1
DEBUG=false
TOP=10

usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS] <directory>

Scan and show the largest directories by disk usage.

OPTIONS:
  -h, --help      Show this help message
  -d, --depth N  Scan N levels deep (default: 1)
  -t, --top N    Show top N folders (default: 10)
  -v, --verbose  Enable debug output

EXAMPLES:
  $(basename "$0") /path/to/project
  $(basename "$0") -d 2 -t 20 /path/to/project
  $(basename "$0") -v /path/to/project
EOF
  exit 0
}

debug() {
  [[ "$DEBUG" == "true" ]] && echo "[DEBUG] $*" >&2
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) usage ;;
    -d|--depth) DEPTH="$2"; shift 2 ;;
    -t|--top) TOP="$2"; shift 2 ;;
    -v|--verbose) DEBUG=true ;;
    -*) echo "Unknown option: $1" >&2; exit 1 ;;
    *) TARGET="$1"; shift ;;
  esac
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

debug "Scanning: $TARGET (depth: $DEPTH, top: $TOP)"

echo "Scanning disk usage in: $TARGET"
echo ""

results=$(du --max-depth=$DEPTH "$TARGET" 2>/dev/null | sort -rh | head -$TOP)

while read -r size path; do
  human=$(numfmt --to=iec-i --suffix=B $size 2>/dev/null || echo "${size}B")
  printf "%-12s %s\n" "$human" "$path"
done <<< "$results"