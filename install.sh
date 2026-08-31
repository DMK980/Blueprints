#!/usr/bin/env bash
# Installs one blueprint folder (e.g. "backend") from DMK980/Blueprints into
# a local project, without needing git, npm, or anything but curl + tar.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/DMK980/Blueprints/main/install.sh | bash -s -- backend
#   ./install.sh backend [destination] [--force]
set -euo pipefail

REPO="DMK980/Blueprints"
BRANCH="main"

usage() {
  cat <<EOF
Usage: install.sh <blueprint> [destination] [--force]

  <blueprint>    Name of the blueprint folder to install (e.g. "backend")
  [destination]  Where to put it (default: ./<blueprint>)
  --force        Overwrite destination if it already exists

Examples:
  curl -fsSL https://raw.githubusercontent.com/${REPO}/${BRANCH}/install.sh | bash -s -- backend
  ./install.sh backend ./server
EOF
}

BLUEPRINT=""
DEST=""
FORCE=0

for arg in "$@"; do
  case "$arg" in
    --force) FORCE=1 ;;
    -h|--help) usage; exit 0 ;;
    *)
      if [ -z "$BLUEPRINT" ]; then BLUEPRINT="$arg"
      elif [ -z "$DEST" ]; then DEST="$arg"
      fi
      ;;
  esac
done

if [ -z "$BLUEPRINT" ]; then
  echo "Error: missing <blueprint> argument." >&2
  usage
  exit 1
fi

DEST="${DEST:-./$BLUEPRINT}"

if [ -e "$DEST" ] && [ "$FORCE" -ne 1 ]; then
  echo "Error: '$DEST' already exists. Use --force to overwrite, or pass a different destination." >&2
  exit 1
fi

for tool in curl tar; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "Error: $tool is required." >&2
    exit 1
  fi
done

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

TARBALL_URL="https://github.com/${REPO}/archive/refs/heads/${BRANCH}.tar.gz"
TOP="Blueprints-${BRANCH}"

if ! curl -fsSL "$TARBALL_URL" | tar -xz -C "$TMP_DIR" "${TOP}/${BLUEPRINT}" 2>/dev/null \
    || [ ! -d "$TMP_DIR/$TOP/$BLUEPRINT" ]; then
  echo "Error: blueprint '${BLUEPRINT}' not found in ${REPO}@${BRANCH}." >&2
  echo "See https://github.com/${REPO} for available blueprints." >&2
  exit 1
fi

if [ "$FORCE" -eq 1 ] && [ -e "$DEST" ]; then
  rm -rf "$DEST"
fi
DEST_PARENT="$(dirname "$DEST")"
[ "$DEST_PARENT" = "." ] || mkdir -p "$DEST_PARENT"
mv "$TMP_DIR/$TOP/$BLUEPRINT" "$DEST"

echo "Installed '${BLUEPRINT}' blueprint into '${DEST}'."
echo "Next: start a coding-agent session in that directory and tell it to follow the instructions in ${BLUEPRINT}/AGENTS.md (Claude Code auto-loads ${BLUEPRINT}/CLAUDE.md instead)."
